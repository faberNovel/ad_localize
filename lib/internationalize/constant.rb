require 'pathname'
require 'yaml'

module Internationalize
  module Constant
    SUPPORTED_PLATFORMS = %w(ios android yml json)
    PLURAL_KEY_SYMBOL = :plural
    SINGULAR_KEY_SYMBOL = :singular
    COMMENT_KEY_SYMBOL = :comment
    COMMENT_KEY_COLUMN_IDENTIFIER = "comment"
    CONFIG = YAML.load_file(Pathname::pwd + 'config.yml')
    EXPORT_FOLDER = 'exports'
    IOS_SINGULAR_EXPORT_FILENAME = "Localizable.strings"
    IOS_PLURAL_EXPORT_FILENAME = "Localizable.stringsdict"
    ANDROID_EXPORT_FILENAME = "strings.xml"
  end
end