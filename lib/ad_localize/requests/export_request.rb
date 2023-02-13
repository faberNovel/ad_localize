# frozen_string_literal: true
module AdLocalize
  module Requests
    class ExportRequest
      DEFAULTS = {
        locales: [],
        bypass_empty_values: false,
        csv_paths: [],
        merge_policy: Interactors::MergeWordings::DEFAULT_POLICY,
        output_path: Pathname.new('exports'),
        spreadsheet_id: nil,
        sheet_ids: %w[0],
        export_all: false,
        verbose: false,
        platforms: Entities::Platform::SUPPORTED_PLATFORMS,
        downloaded_csvs: []
      }

      attr_accessor(:output_dir, :downloaded_csvs)

      attr_reader(
        :locales,
        :bypass_empty_values,
        :csv_paths,
        :merge_policy,
        :output_path,
        :platforms,
        :spreadsheet_id,
        :sheet_ids,
        :export_all,
        :verbose
      )

      def initialize(**args)
        @locales = value_for(optional: args[:locales], default_value: DEFAULTS[:locales])
        @bypass_empty_values = value_for(optional: args[:bypass_empty_values], default_value: DEFAULTS[:bypass_empty_values])
        @csv_paths = value_for(optional: args[:csv_paths], default_value: DEFAULTS[:csv_paths])
        @merge_policy = value_for(optional: args[:merge_policy], default_value: DEFAULTS[:merge_policy])
        @output_path = value_for(optional: args[:output_path], default_value: DEFAULTS[:output_path])
        @platforms = value_for(optional: args[:platforms], default_value: DEFAULTS[:platforms])
        @spreadsheet_id = value_for(optional: args[:spreadsheet_id], default_value: DEFAULTS[:spreadsheet_id])
        @sheet_ids = value_for(optional: args[:sheet_ids], default_value: DEFAULTS[:sheet_ids])
        @export_all = value_for(optional: args[:export_all], default_value: DEFAULTS[:export_all])
        @verbose = value_for(optional: args[:verbose], default_value: DEFAULTS[:verbose])
        @downloaded_csvs = value_for(optional: args[:downloaded_csvs], default_value: DEFAULTS[:downloaded_csvs])
      end

      def value_for(optional:, default_value:)
        optional.presence || default_value
      end

      def has_sheets?
        spreadsheet_id.present?
      end

      def has_csv_paths?
        all_csv_paths.present?
      end

      def many_platforms?
        platforms.size > 1
      end

      def all_csv_paths
        csv_paths + downloaded_csvs.map(&:path)
      end

      def to_s
        "locales: #{locales}, " \
          "bypass_empty_values: #{bypass_empty_values}, " \
          "csv_paths: #{csv_paths}, " \
          "merge_policy: #{merge_policy}, " \
          "output_path: #{output_path}, " \
          "spreadsheet_id: #{spreadsheet_id}, " \
          "sheet_ids: #{sheet_ids}, " \
          "export_all: #{export_all}, " \
          "verbose: #{verbose}, " \
          "platforms: #{platforms}, " \
          "downloaded_csvs: #{downloaded_csvs}"
      end

      private

      def apply_defaults
        @locales = DEFAULTS[:locales]
        @bypass_empty_values = DEFAULTS[:bypass_empty_values]
        @csv_paths = DEFAULTS[:csv_paths]
        @merge_policy = DEFAULTS[:merge_policy]
        @output_path = DEFAULTS[:output_path]
        @platforms = DEFAULTS[:platforms]
        @spreadsheet_id = DEFAULTS[:spreadsheet_id]
        @sheet_ids = DEFAULTS[:sheet_ids]
        @export_all = DEFAULTS[:export_all]
        @verbose = DEFAULTS[:verbose]
        @downloaded_csvs = DEFAULTS[:downloaded_csvs]
      end
    end
  end
end
