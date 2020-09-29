module AdLocalize
  module Requests
    class ExportRequest
      attr_reader(
        :locales,
        :platform_codes,
        :g_spreadsheet_options,
        :output_path,
        :verbose,
        :merge_policy
      # :formatting_convention,
      # :output_strategy, # TODO : allow to select builder and output strategy in export request
      # :wording_builder
      )

      attr_accessor(:csv_paths)

      def initialize(**args)
        @locales = Array(args[:locales])
        @platform_codes = args[:platform_codes].presence || Constant::SUPPORTED_PLATFORMS
        @csv_paths = Array(args[:csv_paths])
        @g_spreadsheet_options = args[:g_spreadsheet_options]
        @verbose = args[:verbose] || false
        @output_path = Pathname.new(args[:output_path].presence || Constant::EXPORT_FOLDER)
        # @formatting_convention = 'ios'
        @merge_policy = args[:merge_policy].presence
        @platform_factory = Platforms::PlatformFactory.new
      end

      def has_csv_files?
        Array(@csv_paths).all? { |csv_path| File.exist?(csv_path) && is_csv?(path: csv_path) }
      end

      def has_g_spreadsheet_options?
        @g_spreadsheet_options.present?
      end

      def multiple_platforms?
        @platform_codes.size > 1
      end

      def valid?
        (has_csv_files? || valid_g_spreadsheet_options?) && valid_platforms? && valid_output_path?
      end

      def ios?
        @platform_codes.include?('ios')
      end

      def android?
        @platform_codes.include?('android')
      end

      def yml?
        @platform_codes.include?('yml')
      end

      def json?
        @platform_codes.include?('json')
      end

      def properties?
        @platform_codes.include?('properties')
      end

      def verbose?
        verbose
      end

      def output_path=(path)
        @output_path = Pathname.new(path)
      end

      def platforms
        @platforms ||= compute_platforms
      end

      private

      def compute_platforms
        @platform_codes.map { |platform_code| @platform_factory.build(code: platform_code) }
      end

      def valid_platforms?
        @platform_codes.size.positive? && (@platform_codes & Constant::SUPPORTED_PLATFORMS).size == @platform_codes.size
      end

      def is_csv?(path:)
        (MIME::Types.of(path).map(&:content_type) & Constant::CSV_CONTENT_TYPES).present?
      end

      def valid_g_spreadsheet_options?
        @g_spreadsheet_options&.valid? && true
      end

      def valid_output_path?
        @output_path&.directory? || !@output_path.exist?
      end
    end
  end
end