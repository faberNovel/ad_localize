module AdLocalize
  module Serializers
    class StringsSerializer < TemplatedSerializer
      def initialize
        super(sanitizer: Sanitizers::IOSToAndroidSanitizer.new)
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/android/strings.xml.erb"
      end

      def variable_binding(locale_wording:)
        {
          singulars: locale_wording.singulars.map { |translation| map_simple_wording(translation:) },
          plurals: locale_wording.plurals.map { |label, translations| map_compound_wording(label:, translations:) }
        }
      end
    end
  end
end
