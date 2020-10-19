module AdLocalize
  module Serializers
    class YAMLSerializer
      def initialize
        @locale_wording_to_hash = Mappers::LocaleWordingToHash.new
      end

      def render(locale_wording:)
        @locale_wording_to_hash.map(locale_wording: locale_wording).to_yaml
      end
    end
  end
end