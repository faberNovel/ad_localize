module AdLocalize
  module Requests
    class ExportRequest
      SUPPORTED_PLATFORMS = %w(ios android yml json properties).freeze
      DEFAULT_EXPORT_FOLDER = 'exports'.freeze
      CSV_CONTENT_TYPES = %w(text/csv text/plain application/csv).freeze
      EMPTY_CONTENT_TYPE = 'inode/x-empty'.freeze

      def initialize(**args)
        @locales = Array(args[:locales].presence)
        @platforms = args[:platforms].blank? ? Entities::Platform.supported_platforms : Array(args[:platforms])
        @csv_paths = Array(args[:csv_paths])
        @g_spreadsheet_options = args[:g_spreadsheet_options]
        @verbose = args[:verbose].presence || false
        @non_empty_values = args[:non_empty_values].presence || false
        @output_path = Pathname.new(args[:output_path].presence || DEFAULT_EXPORT_FOLDER)
        if @csv_paths.size > 1 || @g_spreadsheet_options&.has_multiple_sheets?
          @merge_policy = MergePolicy.new(policy: args[:merge_policy].presence || MergePolicy::DEFAULT_POLICY)
        else
          @merge_policy = nil
        end
      end

      attr_reader(
        :locales,
        :platforms,
        :g_spreadsheet_options,
        :output_path,
        :verbose,
        :non_empty_values,
        :merge_policy
      )

      attr_accessor(:csv_paths)

      def has_csv_files?
        !@csv_paths.blank? && @csv_paths.all? { |csv_path| File.exist?(csv_path) && is_csv?(path: csv_path) }
      end

      def has_empty_files?
        !@csv_paths.blank? && @csv_paths.all? { |csv_path| File.exist?(csv_path) && is_empty?(path: csv_path) }
      end

      def has_g_spreadsheet_options?
        @g_spreadsheet_options.present?
      end

      def multiple_platforms?
        @platforms.size > 1
      end

      def valid?
        platforms_ok = valid_platforms?
        LOGGER.debug("Valid platforms : #{platforms_ok}")
        source_ok = valid_csv_options? || valid_g_spreadsheet_options?
        LOGGER.debug("Valid CSV or GSpreadsheet options : #{source_ok}")
        platforms_ok && source_ok
      end

      def verbose?
        verbose
      end

      def non_empty_values?
        non_empty_values
      end

      def to_s
        "Export Request info\n" +
        "locales : #{export_request.locales.to_sentence}\n" +
        "platforms : #{export_request.platforms.to_sentence}\n" +
        "output_path : #{export_request.output_path}\n" +
        "verbose : #{export_request.verbose}\n" +
        "non_empty_values : #{export_request.non_empty_values}\n" +
        "merge_policy : #{export_request.merge_policy&.policy}\n" +
        "csv_paths : #{export_request.csv_paths.to_sentence}\n" +
        "spreadsheet options : #{export_request.g_spreadsheet_options&.to_s}"
        LOGGER.debug("End Export Request info")
      end

      private

      def valid_csv_options?
        has_csv_files? && (@csv_paths.size == 1 || (@csv_paths.size > 1 && @merge_policy&.valid?))
      end

      def valid_platforms?
        @platforms.size.positive? && (@platforms & Entities::Platform.supported_platforms).size == @platforms.size
      end

      def is_csv?(path:)
        CSV_CONTENT_TYPES.include? content_type(path: path)
      end

      def is_empty?(path:)
        content_type(path: path) == EMPTY_CONTENT_TYPE
      end

      def content_type(path:)
        `file --brief --mime-type "#{path}"`.strip
      end

      def valid_g_spreadsheet_options?
        return false if @g_spreadsheet_options.blank?
        if @g_spreadsheet_options.has_multiple_sheets?
          @g_spreadsheet_options.valid? && @merge_policy&.valid?
        else
          @g_spreadsheet_options.valid?
        end
      end
    end
  end
end