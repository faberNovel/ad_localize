# frozen_string_literal: true
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
        singulars = locale_wording.singulars.map do |translation|
          map_simple_wording(translation: translation)
        end
        { translations: singulars }
      end
    end
  end
end
