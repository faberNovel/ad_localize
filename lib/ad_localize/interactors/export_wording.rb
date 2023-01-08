module AdLocalize
  module Interactors
    class ExportWording
      def call(export_request:, wording:)
        export_request.platforms.each do |platform|
          LOGGER.debug("[#{Entities::Platform.value_to_s(value: platform)}] Starting export...")
          options = build_options(export_request: export_request, platform: platform)
          export_platform(wording:, platform:, options:)
          LOGGER.debug("[#{Entities::Platform.value_to_s(value: platform)}] done !")
        end
      end

      private

      def export_platform(wording:, platform:, options:)
        case platform
        when Entities::Platform::IOS
          GenerateIOSFiles.new.call(wording:, options:)
        when Entities::Platform::ANDROID
          GenerateStrings.new.call(wording:, options:)
        when Entities::Platform::YML
          GenerateYAML.new.call(wording:, options:)
        when Entities::Platform::JSON
          GenerateJSON.new.call(wording:, options:)
        when Entities::Platform::PROPERTIES
          GenerateProperties.new.call(wording:, options:)
        when Entities::Platform::CSV
          GenerateCSV.new.call(wording:, options:)
        end
      end

      def build_options(export_request:, platform:)
        csv_paths = export_request.csv_paths
        platform_output_directory = export_request.output_path
        if export_request.multiple_platforms?
          platform_output_directory = platform_output_directory.join(Entities::Platform.value_to_s(value: platform))
        end
        { csv_paths:, platform_output_directory: }
      end
    end
  end
end