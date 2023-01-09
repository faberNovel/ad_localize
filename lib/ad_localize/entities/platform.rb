module AdLocalize
  module Entities
    module Platform
      IOS = 'ios'
      ANDROID = 'android'
      YML = 'yml'
      JSON = 'json'
      PROPERTIES = 'properties'

      def self.supported_platforms
        [IOS, ANDROID, YML, JSON, PROPERTIES]
      end
    end
  end
end
