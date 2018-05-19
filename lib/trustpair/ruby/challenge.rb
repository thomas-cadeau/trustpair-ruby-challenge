require 'logger'
require 'fileutils'
require 'CSV'
require_relative 'challenge/version'
require_relative 'opendata/opendata_api'

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

      @log = Logger.new(STDOUT)
      api = Trustpair::Ruby::Opendata::OpendataApi.new()

      stats = OpenStruct.new
      stats.valid_sirets_count = 0
      stats.companies_before_1950 = 0
      stats.companies_1950_1975 = 0
      stats.companies_1976_1995 = 0
      stats.companies_before_1995_and_2005 = 0
      stats.companies_after_2005 = 0

      output = []

      # read CSV and get the companies data from the API
      content = CSV.read('../../../data/data.csv', {:headers => true})
      stats.total_input = content['siret'].length
      companies = api.searchBySirets(content['siret'])

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
              :address => (record['numvoie'] || '') + ' ' +
                  (record['typvoie'] || '') + ' ' +
                  (record['libvoie'] || '') + ' ' +
                  (record['codpos'] || '') + ' ' +
                  (record['libcom'] || '')
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

      # export result to a file
      export_companies(output)

      # monitoring:
      display_stats(stats)
    end
  end
end
