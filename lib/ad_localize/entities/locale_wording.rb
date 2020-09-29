module AdLocalize
  module Entities
    class LocaleWording
      attr_reader(:locale, :translations)

      def initialize(locale:, translations:)
        @locale = locale
        @translations = translations
      end

      def has_plural_keys?
        plurals.present?
      end

      def has_info_plist_keys?
        info_plists.present?
      end

      def has_singular_keys?
        singulars.present?
      end

      def has_adaptive_keys?
        adaptives.present?
      end

      def plurals
        @plurals ||= @translations.select { |translation| translation.key.plural? }.group_by { |translation| translation.key.label }
      end

      def info_plists
        @info_plists ||= @translations.select { |translation| translation.key.info_plist? }
      end

      def singulars
        @singulars ||= @translations.select { |translation| translation.key.singular? }
      end

      def adaptives
        @adaptives ||= @translations.select { |translation| translation.key.adaptive? }.group_by { |translation| translation.key.label }
      end

      def add_translation(translation:)
        @translations.push(translation)
      end

      def keys
        @translations.map(&:key)
      end

      def has_key?(key:)
        translation_for(key: key).present?
      end

      def translation_for(key:)
        @translations.find { |translation| translation.key.same_as?(key: key) }
      end
    end
  end
end