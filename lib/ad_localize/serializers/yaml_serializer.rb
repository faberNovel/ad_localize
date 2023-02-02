# frozen_string_literal: true
module AdLocalize
  module Serializers
    class YAMLSerializer
      def render(locale_wording:)
        content = Mappers::LocaleWordingToHash.new.map(locale_wording: locale_wording)
        content.to_yaml
      end
    end
  end
end
