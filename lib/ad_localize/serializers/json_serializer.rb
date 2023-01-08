module AdLocalize
  module Serializers
    class JSONSerializer
      def render(locale_wording:)
        Mappers::LocaleWordingToHash.new.map(locale_wording: locale_wording).to_json
      end
    end
  end
end
