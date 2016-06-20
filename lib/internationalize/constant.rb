require 'pathname'
require 'yaml'

module Internationalize
  module Constant
    SUPPORTED_PLATFORMS = %w(ios android yml json)
    PLURAL_KEY_SYMBOL = :plural
    SINGULAR_KEY_SYMBOL = :singular
    CONFIG = YAML.load_file(Pathname::pwd + 'config.yml')
    EXPORT_FOLDER = 'exports'
  end
end