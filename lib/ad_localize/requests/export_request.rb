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
        platforms: Entities::Platform::SUPPORTED_PLATFORMS
      }

      attr_accessor(:output_dir)

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
        apply_defaults
        @locales = args[:locales] unless args[:locales].blank?
        @bypass_empty_values = args[:bypass_empty_values] unless args[:bypass_empty_values].nil?
        @csv_paths = args[:csv_paths] unless args[:csv_paths].blank?
        @merge_policy = args[:merge_policy] unless args[:merge_policy].blank?
        @output_path = args[:output_path] unless args[:output_path].blank?
        @platforms = args[:platforms] unless args[:platforms].blank?
        @spreadsheet_id = args[:spreadsheet_id] unless args[:spreadsheet_id].blank?
        @sheet_ids = args[:sheet_ids] unless args[:sheet_ids].blank?
        @export_all = args[:export_all] unless args[:export_all].nil?
        @verbose = args[:verbose] unless args[:verbose].nil?
      end

      def has_sheets?
        spreadsheet_id.present?
      end

      def has_csv_paths?
        csv_paths.present?
      end

      def many_platforms?
        platforms.size > 1
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
      end

      # def valid_locales?
      #   locales.is_a? Array
      # end

      # def valid_bypass_empty_values?
      #   [true, false].include? bypass_empty_values
      # end

      # def valid_csv_paths?
      #   csv_paths.is_a?(Array) && csv_paths.present? && csv_paths.all? { |csv_path| File.exist?(csv_path) }
      # end

      # def valid_merge_policy?
      #   Interactors::MergeWordings::MERGE_POLICIES.include?(merge_policy)
      # end

      # def valid_output_path?
      #   output_path.is_a? Pathname
      # end

      # def valid_platforms?
      #   platforms.is_a?(Array) && platforms.select { |platform| Entities::Platform::SUPPORTED_PLATFORMS.include?(platform) }.present?
      # end

      # def valid_spreadsheet_id?
      #   spreadsheet_id.nil? || spreadsheet_id.is_a?(String)
      # end

      # def valid_sheet_ids?
      #   sheet_ids.is_a?(Array) && (spreadsheet_id.nil? || sheet_ids.present?)
      # end

      # def valid_export_all?
      #   [true, false].include? export_all
      # end

      # def valid_verbose?
      #   [true, false].include? verbose
      # end
    end
  end
end
