module AdLocalize
  module Serializers
    class LocalizableStringsdictSerializer < TemplatedSerializer
      LOCALIZABLE_STRINGSDICT_FILENAME = "Localizable.stringsdict".freeze

      def initialize
        super(sanitizer: Sanitizers::IOSSanitizer.new)
      end

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
    end
  end
end
