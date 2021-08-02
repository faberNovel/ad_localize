require 'active_support'
require 'active_support/core_ext'
require 'fileutils'
require 'pathname'
require 'yaml'
require 'json'
require 'csv'
require 'logger'
require 'colorize'
require 'optparse'
require 'nokogiri'
require 'erb'
require 'googleauth'
require 'google/apis/sheets_v4'

require 'ad_localize/version'
require 'ad_localize/ad_logger'
require 'ad_localize/constant'
require 'ad_localize/cli'
require 'ad_localize/option_handler'

require 'ad_localize/repositories/g_sheets_repository'
require 'ad_localize/repositories/file_system_repository'

require 'ad_localize/view_models/translation_view_model'
require 'ad_localize/view_models/translation_group_view_model'

require 'ad_localize/mappers/options_to_export_request'
require 'ad_localize/mappers/csv_path_to_wording'
require 'ad_localize/mappers/locale_wording_to_hash'
require 'ad_localize/mappers/value_range_to_wording'
require 'ad_localize/mappers/translation_mapper'
require 'ad_localize/mappers/translation_group_mapper'
require 'ad_localize/mappers/android_translation_mapper'
require 'ad_localize/mappers/ios_translation_mapper'

require 'ad_localize/entities/key'
require 'ad_localize/entities/translation'
require 'ad_localize/entities/locale_wording'
require 'ad_localize/entities/wording'

require 'ad_localize/requests/g_spreadsheet_options'
require 'ad_localize/requests/export_request'
require 'ad_localize/requests/merge_policy'

require 'ad_localize/interactors/merge_wordings'
require 'ad_localize/interactors/execute_export_request'
require 'ad_localize/interactors/export_csv_files'
require 'ad_localize/interactors/export_g_spreadsheet'
require 'ad_localize/interactors/export_wording'
require 'ad_localize/interactors/platforms/export_android_locale_wording'
require 'ad_localize/interactors/platforms/export_ios_locale_wording'
require 'ad_localize/interactors/platforms/export_json_locale_wording'
require 'ad_localize/interactors/platforms/export_yaml_locale_wording'
require 'ad_localize/interactors/platforms/export_properties_locale_wording'
require 'ad_localize/interactors/platforms/export_csv_locale_wording'
require 'ad_localize/interactors/platforms/export_platform_factory'

require 'ad_localize/serializers/with_template'
require 'ad_localize/serializers/info_plist_serializer'
require 'ad_localize/serializers/localizable_strings_serializer'
require 'ad_localize/serializers/localizable_stringsdict_serializer'
require 'ad_localize/serializers/strings_serializer'
require 'ad_localize/serializers/properties_serializer'
require 'ad_localize/serializers/json_serializer'
require 'ad_localize/serializers/yaml_serializer'



module AdLocalize
  class Error < StandardError; end

  LOGGER = AdLogger.new
end
