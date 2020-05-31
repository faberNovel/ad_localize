module AdLocalize
  class CsvFileManager
    CSV_CONTENT_TYPES = %w(text/csv text/plain)

    class << self
      def csv?(file)
        !file.nil? && CSV_CONTENT_TYPES.include?(`file --brief --mime-type '#{file}'`.strip)
      end

      def select_csvs(files)
        files.select do |file|
          LOGGER.log(:error, :red, "#{file} is not a csv. It will be ignored. Make sure to enable \"Allow external access\" in sharing options or use a service account.") unless self.csv?(file)
          self.csv?(file)
        end
      end
    end
  end
end
