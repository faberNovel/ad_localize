module AdLocalize
  module Entities
    module Platform
      # TODO : refactor
      IOS = 0
      ANDROID = 1
      YML = 2
      JSON = 3
      PROPERTIES = 4
      CSV = 5

      def self.supported_platforms
        [IOS, ANDROID, YML, JSON, PROPERTIES, CSV]
      end

      def self.value_from(string:)
        if string == 'ios'
          IOS
        elsif string == 'android'
          ANDROID
        elsif string == 'yml'
          YML
        elsif string == 'json'
          JSON
        elsif string == 'properties'
          PROPERTIES
        elsif string == 'csv'
          CSV
        end
      end

      def self.value_to_s(value:)
        case value
        when IOS
          'ios'
        when ANDROID
          'android'
        when YML
          'yml'
        when JSON
          'json'
        when PROPERTIES
          'properties'
        when CSV
          'csv'
        end
      end
    end
  end
end
