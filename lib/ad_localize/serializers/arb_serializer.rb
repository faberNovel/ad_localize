# frozen_string_literal: true
module AdLocalize
  module Serializers
    class ARBSerializer
      PLURAL_COUNT_PLACEHOLDER = 'count'
      DART_IDENTIFIER_REGEXP = /\A[a-z][a-zA-Z0-9_]*\z/

      # Flutter expects locales like pt_BR
      def self.arb_locale(locale)
        locale.to_s.tr('-', '_')
      end

      def initialize
        @sanitizer = Sanitizers::ARBSanitizer.new
      end

      def render(locale_wording:)
        content = { '@@locale' => self.class.arb_locale(locale_wording.locale) }
        locale_wording.singulars.each_value do |translation|
          add_singular(content: content, translation: translation)
        end
        locale_wording.plurals.each do |label, translations|
          add_plural(content: content, label: label, translations: translations.values)
        end
        "#{JSON.pretty_generate(content)}\n"
      end

      private

      def add_singular(content:, translation:)
        message = @sanitizer.sanitize(value: translation.value)
        return if message.nil?

        add_entry(
          content: content,
          label: translation.key.label,
          message: message,
          description: translation.comment,
          placeholders: @sanitizer.placeholders(value: translation.value)
        )
      end

      def add_plural(content:, label:, translations:)
        translations = translations.reject { |translation| translation.value.blank? }
        return if translations.empty?

        unless translations.any? { |translation| translation.key.variant_name == 'other' }
          LOGGER.warn("[ARB] Plural key #{label} has no 'other' variant, gen-l10n will reject it")
        end
        variants = translations.map do |translation|
          "#{translation.key.variant_name}{#{@sanitizer.sanitize(value: translation.value)}}"
        end
        placeholders = { PLURAL_COUNT_PLACEHOLDER => 'int' }
        translations.each { |translation| placeholders.merge!(@sanitizer.placeholders(value: translation.value)) }
        add_entry(
          content: content,
          label: label,
          message: "{#{PLURAL_COUNT_PLACEHOLDER}, plural, #{variants.join(' ')}}",
          description: translations.map(&:comment).find(&:present?),
          placeholders: placeholders
        )
      end

      def add_entry(content:, label:, message:, description:, placeholders:)
        key = arb_key(label: label)
        content[key] = message
        metadata = {}
        metadata['description'] = description if description.present?
        metadata['placeholders'] = placeholders.transform_values { |type| { 'type' => type } } if placeholders.any?
        content["@#{key}"] = metadata if metadata.any?
      end

      def arb_key(label:)
        key = label.tr('.', '_')
        LOGGER.warn("[ARB] Key #{key} is not a valid Dart identifier") unless key.match?(DART_IDENTIFIER_REGEXP)
        key
      end
    end
  end
end
