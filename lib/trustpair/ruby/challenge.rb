require 'logger'
require 'fileutils'
require 'CSV'
require_relative 'challenge/version'
require_relative 'opendata/opendata_api'
require_relative 'config'

module Trustpair
  module Ruby
    module Challenge
      def self.export_companies(output)
        @log.debug output
        export_path = Dir.pwd.to_s + '/../../../output'
        FileUtils.mkpath export_path
        File.open("#{export_path}/output.json", "w") do |f|
          f.write(output.to_json)
        end
      end

      def self.display_stats(stats)
        @log.info 'Data processing complete'
        @log.info "* Number of valid SIRETs: [#{stats.valid_sirets_count}]"
        @log.info "* Number of invalid SIRETs: [#{stats.total_input - stats.valid_sirets_count}]"
        @log.info "* Number of companies created before 1950: [#{stats.companies_before_1950}]"
        @log.info "* Number of companies created between 1950 and 1975: [#{stats.companies_1950_1975}]"
        @log.info "* Number of companies created between 1976 and 1995: [#{stats.companies_1976_1995}]"
        @log.info "* Number of companies created before 1995 and 2005: [#{stats.companies_before_1995_and_2005}]"
        @log.info "* Number of companies created after 2005: [#{stats.companies_after_2005}]"
      end

      # method to join address fields
      def self.build_address(record)
        (record['numvoie'] || '') + ' ' +
            (record['typvoie'] || '') + ' ' +
            (record['libvoie'] || '') + ' ' +
            (record['codpos'] || '') + ' ' +
            (record['libcom'] || '')
      end

      def self.search_companies(api, sirets, output, stats)
        unless sirets.empty?
          companies = api.searchBySirets(sirets)

          # loop over the result set of companies found on the open data and parse the results
          companies.each do |company|
            record = company['record']['fields']
            if record
              output[stats.valid_sirets_count] = {
                  :company_name => record['l1_normalisee'],
                  :siret => record['siret'],
                  :ape => record['apen700'],
                  :legal_nature => record['libnj'],
                  :creation_date => record['dcren'],
                  :address => build_address(record)
              }
              if record['dcren']
                creation_date = Date.strptime(record['dcren'], "%Y-%m-%d").year
                stats.companies_before_1950 += creation_date < 1950 ? 1 : 0
                stats.companies_1950_1975 += 1950 <= creation_date && creation_date <= 1975 ? 1 : 0
                stats.companies_1976_1995 += 1976 <= creation_date && creation_date <= 1995 ? 1 : 0
                stats.companies_before_1995_and_2005 += creation_date < 1995 || creation_date < 2005 ? 1 : 0
                stats.companies_after_2005 += creation_date > 2005 ? 1 : 0
              end
              stats.valid_sirets_count += 1
            end
          end
        end
      end

      #### MAIN ####
      @log = Logger.new(STDOUT)
      @log.debug Trustpair::Ruby::Config::CONFIG
      api = Trustpair::Ruby::Opendata::OpendataApi.new()

      stats = OpenStruct.new
      stats.total_input = 0
      stats.valid_sirets_count = 0
      stats.companies_before_1950 = 0
      stats.companies_1950_1975 = 0
      stats.companies_1976_1995 = 0
      stats.companies_before_1995_and_2005 = 0
      stats.companies_after_2005 = 0

      output = []

      # read CSV and get the companies data from the API
      # reading the CSV line by line is less time and memory consuming, if we have large input data files
      sirets = []
      i = 0
      CSV.foreach(File.dirname(__FILE__) + '/../../../data/data.csv', {:headers => true}) do |row|
        sirets[i] = row['siret'] # read the line and keep it
        if sirets.length == Trustpair::Ruby::Opendata::OpendataApi::MAX_ROWS
          # proceed to the API call
          search_companies(api, sirets, output, stats)
          # clean the array and index
          sirets.clear
          i = -1
        end
        stats.total_input += 1
        i += 1
      end
      # proceed to the API call, the array could still have sirets to deal with
      search_companies(api, sirets, output, stats)

      # export result to a file
      export_companies(output)

      # monitoring:
      display_stats(stats)
    end
  end
end
