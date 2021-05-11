module AdLocalize
  module Serializers
    class JSONSerializer
      def initialize
        @locale_wording_to_hash = Mappers::LocaleWordingToHash.new
      end

      def render(locale_wording:)
        @locale_wording_to_hash.map(locale_wording: locale_wording).to_json
      end
    end
  end
end
