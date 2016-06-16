require 'open-uri'
load 'ad_logger.rb'

LOGGER = ADLogger.new

class CsvFileManager
  CSV_CONTENT_TYPES = %w(text/csv text/plain)

  def initialize(options)
    options[:drive_files].map do |variable|
      puts "Downloading file from google drive..."

    end
  end

  class << self
    def csv?(file)
      CSV_CONTENT_TYPES.include? `file --brief --mime-type #{file}`.strip
    end

    # Returns the downloaded file name (it is located in the current directory)
    def download_from_drive(key)
      LOGGER.log(:info, :black, "Downloading file from google drive...")

      File.open("./#{key}.csv", "wb") do |saved_file|
        # the following "open" is provided by open-uri
        open(drive_download_url(key), "rb") do |read_file|
          saved_file.write(read_file.read)
        end
        File.basename saved_file
      end
    end

    def select_csvs(files)
      files.select do |file|
        LOGGER.log(:error, :red, "#{file} is not a csv. It will be ignored") unless file.csv?
        file.csv?
      end
    end

    private
    def drive_download_url(key)
      "https://docs.google.com/spreadsheets/d/#{key}/export?format=csv&id=#{key}"
    end
  end
end