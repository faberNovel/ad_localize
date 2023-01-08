module AdLocalize
  module Serializers
    class LocalizableStringsSerializer
      include WithTemplate

      LOCALIZABLE_STRINGS_FILENAME = "Localizable.strings".freeze

      private

      def template_path
        TEMPLATES_DIRECTORY + "/ios/#{LOCALIZABLE_STRINGS_FILENAME}.erb"
      end

      def variable_binding(locale_wording:)
        {
          translations: locale_wording.singulars.map { |translation| translation_to_binding(translation:) }
        }
      end

      def translation_to_binding(translation:)
        SimpleWordingViewModel.new(
          label: translation.key.label,
          value: sanitize_value(value: translation.value),
          comment: translation.comment
        )
      end

      def sanitize_value(value:)
        return if value.nil? || value.strip.empty?
        value.gsub(/(?<!\\)\"/, "\\\"")
      end
    end
  end
end
