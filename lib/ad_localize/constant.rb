module AdLocalize
  module Constant
    SUPPORTED_PLATFORMS = %w(ios android yml json)
    PLURAL_KEY_SYMBOL = :plural
    ADAPTIVE_KEY_SYMBOL = :adaptive
    SINGULAR_KEY_SYMBOL = :singular
    COMMENT_KEY_SYMBOL = :comment
    INFO_PLIST_KEY_SYMBOL = :info_plist
    COMMENT_KEY_COLUMN_IDENTIFIER = "comment"
    DEFAULT_CONFIG = {
      platforms: {
        export_directory_names: {
          ios: "%{locale}.lproj",
          android: "values%{locale}"
        }
      }
    }
    CONFIG = YAML.load_file(Pathname::pwd + 'config.yml').deep_symbolize_keys rescue DEFAULT_CONFIG
    EXPORT_FOLDER = 'exports'
    IOS_SINGULAR_EXPORT_FILENAME = "Localizable.strings"
    IOS_INFO_PLIST_EXPORT_FILENAME = "InfoPlist.strings"
    IOS_PLURAL_EXPORT_FILENAME = "Localizable.stringsdict"
    ANDROID_EXPORT_FILENAME = "strings.xml"
  end
end
