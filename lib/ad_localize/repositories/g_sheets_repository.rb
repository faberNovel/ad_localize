module AdLocalize
  module Repositories
    class GSheetsRepository
      SCOPES = [Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY]
      ROWS_MAJOR_DIMENSION = 'ROWS'.freeze
      SPREADSHEET_APPLICATION_NAME = 'ad_localize'.freeze

      def initialize
        @service = Google::Apis::SheetsV4::SheetsService.new
        @service.client_options.application_name = SPREADSHEET_APPLICATION_NAME
      end

      def get_sheets_values(g_spreadsheet_options:)
        configure(json_configuration: g_spreadsheet_options.service_account_config) if @service.authorization.nil?
        spreadsheet = @service.get_spreadsheet(g_spreadsheet_options.spreadsheet_id)
        if g_spreadsheet_options.export_all
          spreadsheet.sheets.map { |sheet| get_sheet_values(spreadsheet_id: g_spreadsheet_options.spreadsheet_id, sheet: sheet) }
        elsif g_spreadsheet_options.sheet_ids.nil? || g_spreadsheet_options.sheet_ids.size.zero?
          spreadsheet.sheets[0..0].map { |sheet| get_sheet_values(spreadsheet_id: g_spreadsheet_options.spreadsheet_id, sheet: sheet) }
        else
          spreadsheet.sheets.select do |sheet|
            g_spreadsheet_options.sheet_ids.include?(sheet.properties.sheet_id)
          end.map do |sheet|
            get_sheet_values(spreadsheet_id: g_spreadsheet_options.spreadsheet_id, sheet: sheet)
          end
        end
      end

      private

      def configure(json_configuration:)
        raise ArgumentError.new('No service account configuration') if json_configuration.blank?
        json_key_io = StringIO.new(json_configuration)
        authorizer = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: json_key_io, scope: SCOPES)
        @service.authorization = authorizer
      end

      def get_sheet_values(spreadsheet_id:, sheet:)
        range = sheet.properties.title
        @service.get_spreadsheet_values(spreadsheet_id, range, major_dimension: ROWS_MAJOR_DIMENSION)
      end
    end
  end
end