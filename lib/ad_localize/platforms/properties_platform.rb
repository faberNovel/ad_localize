module AdLocalize
  module Platforms
    class PropertiesPlatform
      def code
        :properties
      end

      def export_settings(locale_wording:)
        {
          properties: {
            filename: "#{locale_wording.locale}.properties",
            binding: { translations: locale_wording.singulars }
          }
        }
      end
    end
  end
end