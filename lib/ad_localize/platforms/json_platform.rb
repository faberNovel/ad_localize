module AdLocalize
  module Platforms
    class JSONPlatform
      def code
        :json
      end

      def export_settings(locale_wording:)
        {
          json: { filename: "#{locale_wording.locale}.json", binding: { locale_wording: locale_wording } }
        }
      end
    end
  end
end