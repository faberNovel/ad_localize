module AdLocalize
  module Interactors
    class ExportWording
      def initialize
        @export_platform_factory = Platforms::ExportPlatformFactory.new
      end

      def call(export_request:, wording:)
        LOGGER.debug("Starting export wording")
        export_request.platforms.each do |platform|
          platform_interactor = @export_platform_factory.build(platform: platform)
          options = build_export_wording_options(wording: wording, export_request: export_request, platform: platform)
          platform_interactor.call(export_wording_options: options)
        end
      end

      private

      def build_export_wording_options(wording:, export_request:, platform:)
        platform_output_directory = export_request.output_path
        platform_output_directory = platform_output_directory.join(platform.to_s) if export_request.multiple_platforms?
        locales = export_request.locales.size.zero? ? wording.locales : wording.locales & export_request.locales

        Requests::ExportWordingOptions.new(
          locales: locales,
          wording: wording,
          platform_output_directory: platform_output_directory,
          bypass_empty_values: export_request.non_empty_values,
          csv_paths: export_request.csv_paths
        )
      end
    end
  end
end