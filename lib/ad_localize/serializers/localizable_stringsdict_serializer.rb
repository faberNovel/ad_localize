module AdLocalize
  module Serializers
    class LocalizableStringsdictSerializer
      include WithTemplate

      LOCALIZABLE_STRINGSDICT_FILENAME = "Localizable.stringsdict".freeze

      private

      def template_path
        TEMPLATES_DIRECTORY + "/ios/#{LOCALIZABLE_STRINGSDICT_FILENAME}.erb"
      end

      def variable_binding(locale_wording:)
        {
          plurals: locale_wording.plurals.map { |label, translations| map_compound_wording(label:, translations:) },
          adaptives: locale_wording.adaptives.map { |label, translations| map_compound_wording(label:, translations:) }
        }
      end

      def sanitize_value(value:)
        return if value.nil? || value.strip.empty?
        value.gsub(/(?<!\\)\"/, "\\\"")
      end
    end
  end
end
