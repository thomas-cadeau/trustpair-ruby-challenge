require_relative 'challenge/version'
require_relative 'opendata/opendata_api'

module Trustpair
  module Ruby
    module Challenge
      api = Trustpair::Ruby::Opendata::OpendataApi.new()
      api.searchBySiret('60203644404227')
    end
  end
end
