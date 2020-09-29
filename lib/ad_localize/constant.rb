module AdLocalize
  module Constant
    SUPPORTED_PLATFORMS = %w(ios android yml json properties)
    PLURAL_KEY_SYMBOL = :plural
    ADAPTIVE_KEY_SYMBOL = :adaptive
    SINGULAR_KEY_SYMBOL = :singular
    COMMENT_KEY_SYMBOL = :comment
    INFO_PLIST_KEY_SYMBOL = :info_plist
    REPLACE_MERGE_POLICY = "replace"
    KEEP_MERGE_POLICY = "keep"
    MERGE_POLICIES = [KEEP_MERGE_POLICY, REPLACE_MERGE_POLICY]
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
    PROPERTIES_EXPORT_FILENAME = "template.properties"
    SPREADSHEET_APPLICATION_NAME = "ad_localize"
    CSV_WORDING_KEYS_COLUMN = "key"
    PLURAL_KEY_REGEXP = /\#\#\{([A-Za-z]+)\}/
    ADAPTIVE_KEY_REGEXP = /\#\#\{(\d+)\}/
    INFO_PLIST_KEY_REGEXP = /(NS.+UsageDescription)|(CF.+Name)/ # see https://developer.apple.com/documentation/bundleresources/information_property_list
    CSV_CONTENT_TYPES = %w(text/csv text/plain)
  end
end
