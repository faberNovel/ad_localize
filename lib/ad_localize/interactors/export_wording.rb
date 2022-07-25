module AdLocalize
  module Interactors
    class ExportWording
      def initialize
        @export_platform_factory = Platforms::ExportPlatformFactory.new
      end

      def call(export_request:, wording:)
        LOGGER.debug("Starting export wording")
        export_request.platforms.each do |platform|
          platform_dir = compute_platform_dir(export_request: export_request, platform: platform)
          export_platform = @export_platform_factory.build(platform: platform)
          export_wording_options = compute_export_wording_options(wording: wording, export_request: export_request, platform: platform)
          if export_platform.should_export_locale_by_locale?
            locales = export_request.locales.size.zero? ? wording.locales : wording.locales & export_request.locales
            locales.each do |locale|
              export_wording_options.locale = locale
              export_platform.call(export_wording_options: export_wording_options)
            end
          else
            export_platform.call(export_wording_options: export_wording_options)
          end
        end
      end

      private

      def compute_platform_dir(export_request:, platform:)
        export_request.multiple_platforms? ? export_request.output_path.join(platform.to_s) : export_request.output_path
      end

      def compute_export_wording_options(wording:, export_request:, platform:)
        platform_dir = compute_platform_dir(export_request: export_request, platform: platform)
        Requests::ExportWordingOptions.new(wording: wording, platform_directory: platform_dir, bypass_empty_values: export_request.non_empty_values, csv_paths: export_request.csv_paths)
      end
    end
  end
end