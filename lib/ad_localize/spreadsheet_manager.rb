require "google/apis/sheets_v4"
require 'googleauth'
require 'open-uri'
require 'stringio'

module AdLocalize
    class SpreadSheetManager
        class << self
            # Returns the downloaded file name (it is located in the current directory)
            def download_from_drive(key, sheet, use_service_account=false)
              LOGGER.log(:info, :green, "Downloading file from google drive...")
              download_string_path = "./#{key}.csv"
              begin
                File.open(download_string_path, "wb") do |saved_file|
                  download_url = drive_download_url(key, sheet)
                  headers = {}
                  if use_service_account
                    LOGGER.log(:debug, :green, "Using a service account...")
                    token = service_account_access_token()
                    headers["Authorization"] = "#{token["token_type"]} #{token["access_token"]}"
                  end
                  # the following "open" is provided by open-uri
                  open(download_url, "rb", headers) do |read_file|
                    saved_file.write(read_file.read)
                  end
                  File.basename saved_file
                end
              rescue => e
                delete_drive_file(download_string_path)
                LOGGER.log(:error, :red, e.message)
                exit
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
