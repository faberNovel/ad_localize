module AdLocalize
  module Interactors
    module Platforms
      class ExportPlatformFactory
        def build(platform:)
          case platform
          when 'json'
            json_builder
          when 'yml'
            yaml_builder
          when 'android'
            android_builder
          when 'ios'
            ios_builder
          when 'properties'
            properties_builder
          when 'csv'
            csv_builder
          else
            raise ArgumentError.new('Unknown platform for builder factory')
          end
        end

        def json_builder
          @json_builder ||= ExportJSONLocaleWording.new
        end

        def yaml_builder
          @yaml_builder ||= ExportYAMLLocaleWording.new
        end

        def android_builder
          @android_builder ||= ExportAndroidLocaleWording.new
        end

        def ios_builder
          @ios_builder ||= ExportIOSLocaleWording.new
        end

        def properties_builder
          @properties_builder ||= ExportPropertiesLocaleWording.new
        end

        def csv_builder
          @csv_builder ||= ExportCSVLocaleWording.new
        end
      end
    end
  end
end