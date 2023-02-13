# frozen_string_literal: true
module AdLocalize
  module Interactors
    class ExportWording
      def call(export_request:, wording:)
        export_request.platforms.each do |platform|
          configure_output_directory(platform: platform, export_request: export_request)
          LOGGER.debug("[#{platform}] Start exporting in #{export_request.output_dir}")
          export_platform(wording: wording, platform: platform, export_request: export_request)
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
          GenerateIOSFiles.new.call(wording: wording, export_request: export_request)
        when Entities::Platform::ANDROID
          GenerateStrings.new.call(wording: wording, export_request: export_request)
        when Entities::Platform::YML
          GenerateYAML.new.call(wording: wording, export_request: export_request)
        when Entities::Platform::JSON
          GenerateJSON.new.call(wording: wording, export_request: export_request)
        when Entities::Platform::PROPERTIES
          GenerateProperties.new.call(wording: wording, export_request: export_request)
        end
      end
    end
  end
end
