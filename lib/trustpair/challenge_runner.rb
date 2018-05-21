require 'logger'
require 'CSV'
require_relative 'challenge/version'
require_relative 'opendata/opendata_api'
require_relative 'model/stats'
require_relative 'config'

module Trustpair
  class ChallengeRunner

    def initialize(api = Trustpair::Opendata::OpendataApi.new(), logger = Logger.new(STDOUT))
      @log = logger
      @log.debug Trustpair::Config::CONFIG
      @api = api
    end

    def run(input_path)
      stats = Stats.new
      output = []

      # read CSV and get the companies data from the API
      # reading the CSV line by line is less time and memory consuming, if we have large input data files
      sirets = []
      i = 0
      CSV.foreach(input_path, {:headers => true}) do |row|
        sirets[i] = row['siret'] # read the line and keep it
        if sirets.length == Trustpair::Opendata::OpendataApi::MAX_ROWS
          # proceed to the API call when reaching the max numbers of rows to process
          search_companies(sirets, output, stats)
          # clear the array and index
          sirets.clear
          i = -1
        end
        stats.total_input += 1
        i += 1
      end
      # proceed to the API call, the array could still have sirets to deal with
      search_companies(sirets, output, stats)

      # monitoring:
      display_stats(stats)

      return output
    end

    private
    # method to join address fields
    def build_address(record)
      (record['numvoie'] || '') + ' ' +
          (record['typvoie'] || '') + ' ' +
          (record['libvoie'] || '') + ' ' +
          (record['codpos'] || '') + ' ' +
          (record['libcom'] || '')
    end

    def display_stats(stats)
      @log.info 'Data processing complete'
      @log.info "* Number of valid SIRETs: [#{stats.valid_sirets_count}]"
      @log.info "* Number of invalid SIRETs: [#{stats.total_input - stats.valid_sirets_count}]"
      @log.info "* Number of companies created before 1950: [#{stats.companies_before_1950}]"
      @log.info "* Number of companies created between 1950 and 1975: [#{stats.companies_1950_1975}]"
      @log.info "* Number of companies created between 1976 and 1995: [#{stats.companies_1976_1995}]"
      @log.info "* Number of companies created before 1995 and 2005: [#{stats.companies_before_1995_and_2005}]"
      @log.info "* Number of companies created after 2005: [#{stats.companies_after_2005}]"
    end

    def search_companies(sirets, output, stats)
      unless sirets.empty?
        companies = @api.searchBySirets(sirets)

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
  end

end
