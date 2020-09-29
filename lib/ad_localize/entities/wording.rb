module AdLocalize
  module Entities
    class Wording
      attr_reader(:default_locale, :locale_wordings)

      def initialize(locale_wordings:, default_locale:)
        @locale_wordings = locale_wordings
        @default_locale = default_locale
      end

      def translations_for(locale:)
        @locale_wordings.find { |locale_wording| locale_wording.locale == locale }
      end

      def locales
        @locale_wordings.map(&:locale)
      end

      def default_locale?(locale:)
        locale == @default_locale
      end
    end
  end
end