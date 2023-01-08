module AdLocalize
  module Serializers
    class YAMLSerializer
      def render(locale_wording:)
        Mappers::LocaleWordingToHash.new.map(locale_wording: locale_wording).to_yaml
      end
    end
  end
end