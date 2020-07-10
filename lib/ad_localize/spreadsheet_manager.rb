require "google/apis/sheets_v4"
require 'googleauth'
require 'open-uri'
require 'stringio'

module AdLocalize
    RATE_LIMIT_SLEEP_DURATION = 10
    class SpreadSheetManager
        class << self
            # Returns the downloaded file name (it is located in the current directory)
            def download_from_drive(key, sheet, use_service_account=false)
                LOGGER.log(:info, :green, "Downloading file from google drive...")
                headers = {}
                if use_service_account
                    headers = drive_download_headers(service_account_authorization)
                end
                download_url = drive_download_url(key, sheet)
                download_path = drive_download_path(key, sheet)
                download_sheet(download_url, download_path, headers)
            end

            def download_all_sheets_from_drive(key)
                authorization = service_account_authorization
                LOGGER.log(:info, :green, 'Fetching all sheets from google drive...')
                sheet_ids = fetch_all_sheet_ids(key, authorization)

                LOGGER.log(:info, :green, 'Downloading all sheets from google drive...')
                headers = drive_download_headers(authorization)
                downloaded_files = []
                sheet_ids.each do |sheet_id|
                    LOGGER.log(:info, :green, "Downloading sheet: #{sheet_id}...")
                    download_url = drive_download_url(key, sheet_id)
                    download_path = drive_download_path(key, sheet_id)
                    download_sheet(download_url, download_path, headers)
                    LOGGER.log(:info, :green, "Sheet: #{sheet_id} downloaded.")
                    downloaded_files.push(download_path)
                end
                downloaded_files
            end

            def delete_drive_file(file)
              Pathname.new(file).delete unless file.nil?
            end

            private

            def download_sheet(download_url, download_path, headers)
                is_first_attempt = true
                begin
                    File.open(download_path, "wb") do |saved_file|
                      # the following "open" is provided by open-uri
                      open(download_url, "rb", headers) do |read_file|
                        saved_file.write(read_file.read)
                      end
                      File.basename saved_file
                    end
                rescue => e
                    if is_rate_limit_error(e) and is_first_attempt
                        is_first_attempt = false
                        LOGGER.log(:warn, :yellow, "Rate limits, slowing down...")
                        sleep(RATE_LIMIT_SLEEP_DURATION)
                        retry
                    else
                        LOGGER.log(:error, :red, "Failed to download. (#{e.message})")
                        delete_drive_file(download_path)
                        exit
                    end
                end
            end

            def drive_download_url(key, sheet)
              query_id = sheet ? "gid=#{sheet}" : "id=#{key}"
              "https://docs.google.com/spreadsheets/d/#{key}/export?format=csv&#{query_id}"
            end

            def drive_download_path(key, sheet)
                path_suffix = sheet ? "-#{sheet}" : ''
                "./#{key}#{path_suffix}.csv"
            end

            def drive_download_headers(authorization = nil)
                headers = {}
                if authorization
                    token = authorization.fetch_access_token!
                    headers["Authorization"] = "#{token["token_type"]} #{token["access_token"]}"
                end
                headers
            end

            def fetch_all_sheet_ids(key, authorization)
                service = Google::Apis::SheetsV4::SheetsService.new
                service.client_options.application_name = Constant::SPREADSHEET_APPLICATION_NAME
                service.authorization = authorization
                response = service.get_spreadsheet(key)
                response.sheets.map { |s| s.properties.sheet_id }
            end

            def service_account_authorization
                scopes = [
                    Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY,
                    "https://www.googleapis.com/auth/drive.readonly"
                ]
                json_key_io = StringIO.new ENV["GCLOUD_CLIENT_SECRET"]
                Google::Auth::ServiceAccountCredentials.make_creds(
                  json_key_io: json_key_io,
                  scope: scopes
                )
            end

            def is_rate_limit_error(error)
                error.io.status[0] = 429
            end
        end
    end
end
