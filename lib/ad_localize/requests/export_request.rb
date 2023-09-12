# frozen_string_literal: true
module AdLocalize
  module Requests
    class ExportRequest
      DEFAULTS = {
        locales: [],
        bypass_empty_values: false,
        auto_escape_percent: false,
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

      attr_accessor :output_dir

      attr_reader(
        :locales,
        :bypass_empty_values,
        :auto_escape_percent,
        :csv_paths,
        :merge_policy,
        :output_path,
        :platforms,
        :spreadsheet_id,
        :sheet_ids,
        :export_all,
        :verbose,
        :downloaded_csvs
      )

      def initialize
        @locales = DEFAULTS[:locales]
        @bypass_empty_values = DEFAULTS[:bypass_empty_values]
        @auto_escape_percent = DEFAULTS[:auto_escape_percent]
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

      def locales=(value)
        return unless value.is_a? Array

        @locales = value.compact
      end

      def bypass_empty_values=(value)
        @bypass_empty_values = [true, 'true'].include?(value)
      end

      def auto_escape_percent=(value)
        @auto_escape_percent = [true, 'true'].include?(value)
      end

      def csv_paths=(value)
        return unless value.is_a? Array

        @csv_paths = value.compact.map { |path| Pathname.new(path) }
      end

      def merge_policy=(value)
        @merge_policy = value unless value.blank?
      end

      def output_path=(value)
        @output_path = Pathname.new(value) unless value.blank?
      end

      def platforms=(value)
        return unless value.is_a? Array

        @platforms = value.compact & DEFAULTS[:platforms]
      end

      def spreadsheet_id=(value)
        @spreadsheet_id = value unless value.blank?
      end

      def sheet_ids=(value)
        return unless value.is_a? Array

        @sheet_ids = value.compact
      end

      def export_all=(value)
        @export_all = [true, 'true'].include?(value)
      end

      def verbose=(value)
        @verbose = [true, 'true'].include?(value)
      end

      def downloaded_csvs=(value)
        return unless value.is_a? Array

        @downloaded_csvs = value.compact
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
          "auto_escape_percent: #{auto_escape_percent}, " \
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
    end
  end
end
