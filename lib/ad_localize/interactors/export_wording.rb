module AdLocalize
  module Interactors
    class ExportWording
      def initialize
        @export_platform_factory = Platforms::ExportPlatformFactory.new
      end

      def call(export_request:, wording:)
        LOGGER.debug("Starting export wording")
        locales = export_request.locales.size.zero? ? wording.locales : wording.locales & export_request.locales
        export_request.platforms.each do |platform|
          locales.each do |locale|
            platform_dir = compute_platform_dir(export_request: export_request, platform: platform)
            export_platform = @export_platform_factory.build(platform: platform)
            export_platform.call(wording: wording, locale: locale, platform_dir: platform_dir)
          end
        end
      end

      private

      def compute_platform_dir(export_request:, platform:)
        export_request.multiple_platforms? ? export_request.output_path.join(platform.to_s) : export_request.output_path
      end
    end
  end
end