module AdLocalize
  module Platforms
    class YamlPlatform
      def code
        :yml
      end

      def export_settings(locale_wording:)
        {
          yml: { filename: "#{locale_wording.locale}.yml", binding: { locale_wording: locale_wording }}
        }
      end
    end
  end
end