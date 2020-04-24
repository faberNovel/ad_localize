module AdLocalize
  class CsvFileManager
    CSV_CONTENT_TYPES = %w(text/csv text/plain)

    class << self
      def csv?(file)
        !file.nil? && CSV_CONTENT_TYPES.include?(`file --brief --mime-type '#{file}'`.strip)
      end

      # Returns the downloaded file name (it is located in the current directory)
      def download_from_drive(key, sheet, use_service_account=false)
        LOGGER.log(:info, :green, "Downloading file from google drive...")
        download_string_path = "./#{key}.csv"
        begin
          File.open(download_string_path, "wb") do |saved_file|
            download_url = drive_download_url(key, sheet)
            if use_service_account
                LOGGER.log(:debug, :green, "Using a service account...")
                token = service_account_access_token()
                # the following "open" is provided by open-uri
                open(download_url, "rb",
                  "Authorization" => "#{token["token_type"]} #{token["access_token"]}"
                ) do |read_file|
                  saved_file.write(read_file.read)
                end
            else
                # the following "open" is provided by open-uri
                open(download_url, "rb") do |read_file|
                  saved_file.write(read_file.read)
                end
            end
            File.basename saved_file
          end
        rescue => e
          delete_drive_file(download_string_path)
          LOGGER.log(:error, :red, e.message)
          exit
        end
      end

      def select_csvs(files)
        files.select do |file|
          LOGGER.log(:error, :red, "#{file} is not a csv. It will be ignored") unless self.csv?(file)
          self.csv?(file)
        end
      end

      def delete_drive_file(file)
        Pathname.new(file).delete unless file.nil?
      end

      private
      def drive_download_url(key, sheet)
        query_id = sheet ? "gid=#{sheet}" : "id=#{key}"
        "https://docs.google.com/spreadsheets/d/#{key}/export?format=csv&#{query_id}"
      end
      private
      def service_account_access_token()
          scope = "https://www.googleapis.com/auth/drive.readonly"
          json_key_io = StringIO.new ENV["GCLOUD_CLIENT_SECRET"]
          authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
            json_key_io: json_key_io,
            scope: scope
          )
         authorizer.fetch_access_token!
      end
    end
  end
end
