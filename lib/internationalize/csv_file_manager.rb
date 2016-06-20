require 'open-uri'

module Internationalize
  class CsvFileManager
    CSV_CONTENT_TYPES = %w(text/csv text/plain)

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
          LOGGER.log(:error, :red, "#{file} is not a csv. It will be ignored") unless self.csv?(file)
          self.csv?(file)
        end
      end

      private
      def drive_download_url(key)
        "https://docs.google.com/spreadsheets/d/#{key}/export?format=csv&id=#{key}"
      end
    end
  end
end