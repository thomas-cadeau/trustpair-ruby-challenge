require 'net/http'
require 'json'
require 'logger'

module Trustpair
  module Ruby
    module Opendata

      # this is the api to call the open data resources of sirene@public
      class OpendataApi

        def initialize (logger = Logger.new(STDOUT))
          @host = 'data.opendatasoft.com'
          @port = '443'
          @main_path = '/api/v2/catalog/datasets/sirene@public/records'
          @log = logger
        end

        def set_logger(logger)
          @log = logger
        end

        def searchBySiret(siret)
          # TODO: improve this section to deal with redirects
          response = Net::HTTP.start(@host, @port, :use_ssl => true) {|http|
            uri = URI.parse("https://#{@host}:#{@port}#{@main_path}?where=siret%3D#{siret}&pretty=false&timezone=UTC")
            @log.debug uri
            http.request(Net::HTTP::Get.new(uri.path + '?' + uri.query))
          }
          validate response

          # getting the data
          records = JSON.parse(response.body)['records']
          record = nil
          if records.empty?
            @log.debug "could not find any record with siret number #{siret}"
          else
            @log.debug "found record #{records[0]['record']} by siret number #{siret}"
            record = records[0]['record']['fields']
          end

          return record
        end

        def searchBySirets(sirets)
          sirets_query = ''
          sirets.each {|siret|
            sirets_query+=" or (siret%3D#{siret})"
          }
          if !sirets_query.empty?
            sirets_query = sirets_query[4..-1]
          end
          # TODO: improve this section to deal with redirects
          response = Net::HTTP.start(@host, @port, :use_ssl => true) {|http|
            uri = URI.parse("https://#{@host}:#{@port}#{@main_path}?where=#{sirets_query}&pretty=false&timezone=UTC&rows=100")#WARN: limited to 100 rows
            @log.debug uri
            http.request(Net::HTTP::Get.new(uri.path + '?' + uri.query))
          }
          validate response

          # getting the data
          JSON.parse(response.body)['records']
        end

        private
        def validate(entity)
          if entity.code != '200'
            @log.error("Problem when calling the Opendata API")
            @log.error("Status: #{entity.code}")
            @log.error("Body: #{entity.body}")
          end
        end
      end
    end
  end
end
