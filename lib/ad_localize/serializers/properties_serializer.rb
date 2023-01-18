module AdLocalize
  module Serializers
    class PropertiesSerializer < TemplatedSerializer
      def initialize
        super(sanitizer: Sanitizers::PassThroughSanitizer.new)
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/properties/template.properties.erb"
      end

      def variable_binding(locale_wording:)
        {
          translations: locale_wording.singulars.map { |translation| map_simple_wording(translation:) }
        }
      end
    end
  end
end
