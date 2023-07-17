# frozen_string_literal: true
module AdLocalize
  module Mappers
    class OptionsToExportRequest
      def map(options:)
        args = options_to_args(options)
        Requests::ExportRequest.new(args)
      end

      private

      def options_to_args(hash)
        {
          locales: sanitized_locales(hash[:locales]),
          bypass_empty_values: sanitized_bypass_empty_values(hash[:'non-empty-values']),
          csv_paths: sanitized_csv_paths(hash[:csv_paths]),
          merge_policy: sanitized_merge_policy(hash[:'merge-policy']),
          output_path: sanitized_output_path(hash[:'target-dir']),
          platforms: sanitized_platforms(hash[:only]),
          spreadsheet_id: sanitized_spreadsheet_id(hash[:'drive-key']),
          sheet_ids: sanitized_sheet_ids(hash[:sheets]),
          export_all: sanitized_export_all(hash[:'export-all-sheets']),
          verbose: sanitized_verbose(hash[:debug])
        }
      end

      def sanitized_locales(locales_value)
        return Requests::ExportRequest::DEFAULTS[:locales] if locales_value.blank?

        Array(locales_value)
      end

      def sanitized_bypass_empty_values(bypass_empty_flag)
        return Requests::ExportRequest::DEFAULTS[:bypass_empty_values] if bypass_empty_flag.nil?

        bypass_empty_flag
      end

      def sanitized_csv_paths(csv_path_list)
        return Requests::ExportRequest::DEFAULTS[:csv_paths] if csv_path_list.blank?

        Array(csv_path_list)
      end

      def sanitized_merge_policy(merge_policy_flag)
        return Requests::ExportRequest::DEFAULTS[:merge_policy] if merge_policy_flag.nil?

        merge_policy_flag
      end

      def sanitized_output_path(output_path_value)
        return Requests::ExportRequest::DEFAULTS[:output_path] if output_path_value.blank?

        Pathname.new(output_path_value)
      end

      def sanitized_platforms(platform_list)
        return Requests::ExportRequest::DEFAULTS[:platforms] if platform_list.blank?

        Array(platform_list) & Entities::Platform::SUPPORTED_PLATFORMS
      end

      def sanitized_spreadsheet_id(spreadsheet_id_value)
        return Requests::ExportRequest::DEFAULTS[:spreadsheet_id] if spreadsheet_id_value.blank?

        spreadsheet_id_value
      end

      def sanitized_sheet_ids(sheet_id_list)
        return Requests::ExportRequest::DEFAULTS[:sheet_ids] if sheet_id_list.blank?

        Array(sheet_id_list)
      end

      def sanitized_export_all(export_all_sheets_flag)
        return Requests::ExportRequest::DEFAULTS[:export_all] if export_all_sheets_flag.nil?

        export_all_sheets_flag
      end

      def sanitized_verbose(verbose_flag)
        return Requests::ExportRequest::DEFAULTS[:verbose] if verbose_flag.nil?

        verbose_flag
      end
    end
  end
end
