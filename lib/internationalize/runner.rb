require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext'
require 'byebug'
require 'fileutils'
require_relative 'ad_logger'
require_relative 'constant'
require_relative 'option_handler'
require_relative 'csv_parser'
require_relative 'csv_file_manager'
Internationalize::Constant::SUPPORTED_PLATFORMS.each { |platform| require_relative "platform_formatters/#{platform}_formatter" }

module Internationalize
  LOGGER = ADLogger.new

  class Runner
    attr_accessor :options

    def initialize
      @options = OptionHandler.parse
    end

    def run
      LOGGER.log(:info, :black, "OPTIONS : #{options}")
      input_files = (ARGV + [options.dig(:drive_key)]).compact # drive_key can be nil
      if input_files.length.zero?
        LOGGER.log(:error, :red, "No CSV to parse. Use option -h to see how to use this script")
      else
        file_to_parse = ARGV.first
        LOGGER.log(:warn, :yellow, "Only one CSV can be treated - the priority goes to #{file_to_parse}") if input_files.length > 1
        if ARGV.empty?
          options[:drive_file] = CsvFileManager.download_from_drive(options.dig(:drive_key))
          file_to_parse = options.dig(:drive_file)
        end
        CsvFileManager.csv?(file_to_parse) ? export(file_to_parse) : LOGGER.log(:error, :red, "#{file_to_parse} is not a csv or is not accessible to anyone with the link")
        CsvFileManager.delete_drive_file(options[:drive_file]) if options[:drive_file]
      end
    end

    private
    def export(file)
      LOGGER.log(:info, :black, "********* PARSING #{file} *********")
      LOGGER.log(:info, :black, "Extracting data from file...")
      parser = CsvParser.new
      data = parser.extract_data(file)
      if data.empty?
        LOGGER.log(:error, :red, "No data were found in the file - cannot start the file generation process")
      else
        export_platforms = options.dig(:only) || Constant::SUPPORTED_PLATFORMS
        export_platforms.each do |platform|
          platform_formatter = "Internationalize::Platform::#{platform.to_s.camelize}Formatter".constantize.new(parser.locales.first, options.dig(:output_path))
          parser.locales.each do |locale|
            platform_formatter.export(locale, data)
          end
        end
      end
    end
  end
end
