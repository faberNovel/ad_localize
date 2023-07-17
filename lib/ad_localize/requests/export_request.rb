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

      def initialize(args)
        apply_defaults
        @locales = args[:locales] unless args[:locales].blank?
        @bypass_empty_values = args[:bypass_empty_values] unless args[:bypass_empty_values].blank?
        @csv_paths = Array(args[:csv_paths]).map { |path| Pathname.new(path) } unless args[:csv_paths].blank?
        @merge_policy = args[:merge_policy] unless args[:merge_policy].blank?
        @output_path = Pathname.new(args[:output_path]) unless args[:output_path].blank?
        @platforms = Array(args[:platforms]) & DEFAULTS[:platforms] unless args[:platforms].blank?
        @spreadsheet_id = args[:spreadsheet_id] unless args[:spreadsheet_id].blank?
        @sheet_ids = Array(args[:sheet_ids]) unless args[:sheet_ids].blank?
        @export_all = args[:export_all] unless args[:export_all].blank?
        @verbose = args[:verbose] unless args[:verbose].blank?
        @downloaded_csvs = Array(args[:downloaded_csvs]) unless args[:downloaded_csvs].blank?
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
