require 'yaml'

module Trustpair
  module Ruby
    module Config
      CONFIG = YAML.load_file('../../../exe/config.yml')
    end
  end
end

