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

require 'ad_localize/view_models/simple_wording_view_model'
require 'ad_localize/view_models/compound_wording_view_model'

require 'ad_localize/parsers/key_parser'
require 'ad_localize/parsers/csv_parser'

require 'ad_localize/mappers/options_to_export_request'
require 'ad_localize/mappers/locale_wording_to_hash'

require 'ad_localize/entities/key'
require 'ad_localize/entities/locale_wording'
require 'ad_localize/entities/platform'
require 'ad_localize/entities/simple_wording'

require 'ad_localize/requests/g_spreadsheet_options'
require 'ad_localize/requests/export_request'
require 'ad_localize/requests/export_wording_options'
require 'ad_localize/requests/merge_policy'

require 'ad_localize/interactors/merge_wordings'
require 'ad_localize/interactors/execute_export_request'
require 'ad_localize/interactors/export_csv_files'
require 'ad_localize/interactors/export_g_spreadsheet'
require 'ad_localize/interactors/export_wording'
require 'ad_localize/interactors/generate_info_plist'
require 'ad_localize/interactors/generate_ios_files'
require 'ad_localize/interactors/generate_json'
require 'ad_localize/interactors/generate_localizable_strings'
require 'ad_localize/interactors/generate_localizable_strings_dict'
require 'ad_localize/interactors/generate_properties'
require 'ad_localize/interactors/generate_strings'
require 'ad_localize/interactors/generate_yaml'

require 'ad_localize/serializers/with_template'
require 'ad_localize/serializers/info_plist_serializer'
require 'ad_localize/serializers/localizable_strings_serializer'
require 'ad_localize/serializers/localizable_stringsdict_serializer'
require 'ad_localize/serializers/strings_serializer'
require 'ad_localize/serializers/properties_serializer'
require 'ad_localize/serializers/json_serializer'
require 'ad_localize/serializers/yaml_serializer'

require 'ad_localize/validators/key_validator'

module AdLocalize
  class Error < StandardError; end

  LOGGER = AdLogger.new
end
