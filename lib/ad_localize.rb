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
require 'mime/types'
require 'erb'

require 'ad_localize/version'
require 'ad_localize/ad_logger'
require 'ad_localize/constant'
require 'ad_localize/csv_file_manager'
require 'ad_localize/spreadsheet_manager'
require 'ad_localize/csv_parser'
require 'ad_localize/option_handler'
require 'ad_localize/runner'
require 'ad_localize/platform/platform_formatter'
require 'ad_localize/platform/android_formatter'
require 'ad_localize/platform/ios_formatter'
require 'ad_localize/platform/json_formatter'
require 'ad_localize/platform/yml_formatter'
require 'ad_localize/platform/properties_formatter'

module AdLocalize
  class Error < StandardError; end

  LOGGER = AdLogger.new
end
