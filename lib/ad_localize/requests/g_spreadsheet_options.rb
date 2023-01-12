module AdLocalize
  module Requests
    class GSpreadsheetOptions
      attr_accessor(
        :spreadsheet_id,
        :sheet_ids,
        :export_all,
        :service_account_config
      )

      def initialize(**args)
        @spreadsheet_id = args[:spreadsheet_id]
        @sheet_ids = Array(args[:sheet_ids])
        @export_all = args[:export_all] || false
        @service_account_config = args[:service_account_config].presence
      end

      def valid?
        (spreadsheet_id && !export_all) || (spreadsheet_id && service_account_config.present?)
      end

      def public_download_urls
        return [] if @service_account_config
        if @sheet_ids.size.zero?
          [public_download_url(sheet_id: nil)]
        else
          @sheet_ids.map { |sheet_id| public_download_url(sheet_id: sheet_id) }
        end
      end

      def has_multiple_sheets?
        export_all || @sheet_ids.size > 1
      end

      def to_s
        "spreadsheet_id : #{g_options.spreadsheet_id}, " +
        "sheet_ids : #{g_options.sheet_ids.to_sentence}, " +
        "export_all: #{g_options.export_all}, " +
        "service_account: #{g_options.service_account_config.present?}\n"
      end

      private

      def public_download_url(sheet_id:)
        query_id = sheet_id.blank? ? "id=#{@spreadsheet_id}" : "gid=#{sheet_id}"
        "https://docs.google.com/spreadsheets/d/#{@spreadsheet_id}/export?format=csv&#{query_id}"
      end

      def valid_export_all_config
        export_all && service_account_config.present?
      end
    end
  end
end