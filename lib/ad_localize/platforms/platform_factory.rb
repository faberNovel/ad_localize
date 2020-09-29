module AdLocalize
  module Platforms
    class PlatformFactory
      def build(code:)
        case code
        when :ios, 'ios'
          build_ios
        when :android, 'android'
          build_android
        when :json, 'json'
          build_json
        when :yml, 'yml'
          build_yml
        when :properties, 'properties'
          build_properties
        else
          raise ArgumentError.new('unknown platform code')
        end
      end

      private

      def build_ios
        IOSPlatform.new
      end

      def build_android
        AndroidPlatform.new
      end

      def build_json
        JSONPlatform.new
      end

      def build_yml
        YamlPlatform.new
      end

      def build_properties
        PropertiesPlatform.new
      end
    end
  end
end