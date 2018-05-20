require 'yaml'

module Trustpair
  module Ruby
    module Config
      CONFIG = YAML.load_file(File.dirname(__FILE__) + '/../../../exe/config.yml')
    end
  end
end

