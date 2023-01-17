module AdLocalize
  module Interactors
    class ExportWording
      def call(export_request:, wording:)
        export_request.platforms.each do |platform|
          LOGGER.debug("[#{platform}] Starting export...")
          configure_output_directory(platform:, export_request:)
          export_platform(wording:, platform:, export_request:)
          LOGGER.debug("[#{platform}] done !")
        end
      end

      private

      def configure_output_directory(platform:, export_request:)
        if export_request.many_platforms?
          export_request.output_dir = export_request.output_path.join(platform)
        else
          export_request.output_dir = export_request.output_path
        end
      end

      def export_platform(wording:, platform:, export_request:)
        case platform
        when Entities::Platform::IOS
          GenerateIOSFiles.new.call(wording:, export_request:)
        when Entities::Platform::ANDROID
          GenerateStrings.new.call(wording:, export_request:)
        when Entities::Platform::YML
          GenerateYAML.new.call(wording:, export_request:)
        when Entities::Platform::JSON
          GenerateJSON.new.call(wording:, export_request:)
        when Entities::Platform::PROPERTIES
          GenerateProperties.new.call(wording:, export_request:)
        end
      end
    end
  end
end
