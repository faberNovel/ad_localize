module AdLocalize
  module Serializers
    class PropertiesSerializer
      include WithTemplate

      private

      def translation_to_binding(translation:)
        SimpleWordingViewModel.new(
          label: translation.key.label,
          value: sanitize_value(value: translation.value),
          comment: translation.comment,
          variant_name: translation.key.variant_name
        )
      end

      def template_path
        TEMPLATES_DIRECTORY + "/properties/template.properties.erb"
      end

      def variable_binding(locale_wording:)
        {
          translations: locale_wording.singulars.map { |translation| translation_to_binding(translation:) }
        }
      end

      def sanitize_value(value:)
        value
      end
    end
  end
end