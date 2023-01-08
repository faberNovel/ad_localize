module AdLocalize
  module Serializers
    class PropertiesSerializer
      include WithTemplate

      private

      def template_path
        TEMPLATES_DIRECTORY + "/properties/template.properties.erb"
      end

      def variable_binding(locale_wording:)
        {
          translations: locale_wording.singulars.map { |translation| map_simple_wording(translation:) }
        }
      end

      def sanitize_value(value:)
        value
      end
    end
  end
end