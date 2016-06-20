require 'optparse'
require 'pathname'
require_relative 'constant'

module Internationalize
  class OptionHandler
    GOOGLE_DRIVE_DOCUMENT_ID = { length: 32, regexp: /\A\w+\Z/ }

    class << self
      def parse
        args = { debug: false , drive_keys: [], only: nil}

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: ruby exportCSVStrings.rb [options] file(s)"


          opts.on("-h", "--help", "Prints help") do
            puts opts
            exit
          end
          opts.on("-d", "--debug", "Run in debug mode") do
            args[:debug] = true
            LOGGER.debug!
          end
          opts.on("-k", "--drive-key key1,key2", Array, "Use google drive spreadsheets. Keys must be separated by a comma") do |keys|
            args[:drive_keys] = filter_option_args("-k", keys) { |key| !!(key =~ GOOGLE_DRIVE_DOCUMENT_ID.dig(:regexp)) and (key.size >= GOOGLE_DRIVE_DOCUMENT_ID.dig(:length)) }
          end
          opts.on("-o", "--only platform1,platform2", Array, "Only generate localisation files for the specified platforms. Supported platforms : #{Constant::SUPPORTED_PLATFORMS.join(', ')}") do |platforms|
            args[:only] = filter_option_args("-o", platforms) { |platform| !!Constant::SUPPORTED_PLATFORMS.index(platform) }
          end
          opts.on("-t", "--target-dir PATH", String, "Path to the target directory") do |output_path|
            pn = Pathname.new(output_path)
            if pn.directory? and pn.readable? and pn.writable?
              args[:output_path] = output_path
            else
              raise ArgumentError.new("Invalid target directory. Check the permissions")
            end
          end
        end

        begin
          opt_parser.parse!
        rescue OptionParser::MissingArgument => e
          LOGGER.log(:error, :red, "Missing argument for option #{e.args.join(',')}")
        rescue ArgumentError => e
          LOGGER.log(:error, :red, e.message)
        end
        args
      end

      private
      def filter_option_args(option, args)
        result = args.select { |arg| yield(arg) }
        invalid_args = args - result
        LOGGER.log(:debug, :red, "Invalid arg(s) for option #{option}: #{invalid_args.join(', ')}") unless invalid_args.empty?
        result
      end
    end
  end
end