# frozen_string_literal: true
module AdLocalize
  module Serializers
    class JSONSerializer
      def render(locale_wording:)
        content = Mappers::LocaleWordingToHash.new.map(locale_wording: locale_wording)
        content.to_json
      end
    end
  end
end
