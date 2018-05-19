require 'logger'
require 'CSV'
require_relative 'challenge/version'
require_relative 'opendata/opendata_api'

module Trustpair
  module Ruby
    module Challenge
      @log = Logger.new(STDOUT)

      api = Trustpair::Ruby::Opendata::OpendataApi.new()

      valid_sirets_count = 0
      companies_before_1950 = 0
      companies_1950_1975 = 0
      companies_1976_1995 = 0
      companies_before_1995_and_2005 = 0
      companies_after_2005 = 0
      output = []

      # read CSV and get the companies data from the API
      content = CSV.read('../../../data/data.csv', {:headers => true})
      total_input = content['siret'].length
      companies = api.searchBySirets(content['siret'])

      # loop over the result set of companies found on the open data and parse the results
      companies.each do |company|
        record = company['record']['fields']
        if record
          output[valid_sirets_count] = {
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
            companies_before_1950 += creation_date < 1950 ? 1 : 0
            companies_1950_1975 += 1950 <= creation_date && creation_date <= 1975 ? 1 : 0
            companies_1976_1995 += 1976 <= creation_date && creation_date <= 1995 ? 1 : 0
            companies_before_1995_and_2005 += creation_date < 1995 || creation_date < 2005 ? 1 : 0
            companies_after_2005 += creation_date > 2005 ? 1 : 0
          end
          valid_sirets_count += 1
        end
      end

      # TODO: export to a file
      @log.debug output.to_json
      # monitoring:
      @log.info 'Data processing complete'
      @log.info "* Number of valid SIRETs: [#{valid_sirets_count}]"
      @log.info "* Number of invalid SIRETs: [#{total_input - valid_sirets_count}]"
      @log.info "* Number of companies created before 1950: [#{companies_before_1950}]"
      @log.info "* Number of companies created between 1950 and 1975: [#{companies_1950_1975}]"
      @log.info "* Number of companies created between 1976 and 1995: [#{companies_1976_1995}]"
      @log.info "* Number of companies created before 1995 and 2005: [#{companies_before_1995_and_2005}]"
      @log.info "* Number of companies created after 2005: [#{companies_after_2005}]"
    end
  end
end
