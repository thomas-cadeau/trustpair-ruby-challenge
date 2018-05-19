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

        def searchBySirets(sirets)
          sirets_query = ''
          sirets.each {|siret|
            sirets_query += "or(siret%3D#{siret})"
          }
          if !sirets_query.empty?
            sirets_query = sirets_query[2..-1] # to remove the first 'or' condition
            uri = "https://#{@host}:#{@port}#{@main_path}?where=#{sirets_query}&pretty=false&timezone=UTC&rows=100" #WARN: limited to 100 rows
            @log.debug uri
            response = fetch(uri)
            validate response

            # getting the data
            return JSON.parse(response.body)['records']
          end
        end

        private
        def fetch(uri_str, limit = 10)
          raise Exception, 'HTTP redirect too deep' if limit == 0

          url = URI.parse(uri_str)
          req = Net::HTTP::Get.new(url.path + '?' + url.query)
          response = Net::HTTP.start(url.host, url.port, :use_ssl=> true) {| http | http.request(req)}
          case response
            when Net::HTTPSuccess then
              response
            when Net::HTTPRedirection then
              fetch(response['location'], limit - 1)
            else
              response.error!
          end
        end

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
