require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext'
require 'byebug'
require 'fileutils'
require_relative 'ad_localize/ad_logger'
require_relative 'ad_localize/constant'
require_relative 'ad_localize/option_handler'
require_relative 'ad_localize/csv_parser'
require_relative 'ad_localize/csv_file_manager'
Internationalize::Constant::SUPPORTED_PLATFORMS.each { |platform| require_relative "ad_localize/platform_formatters/#{platform}_formatter" }
require_relative 'ad_localize/runner'

module Internationalize
  LOGGER = ADLogger.new

  def self.run
    Runner.new.run
  end
end
