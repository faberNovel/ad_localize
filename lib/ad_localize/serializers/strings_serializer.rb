# frozen_string_literal: true
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
        singulars = locale_wording.singulars.map do |_, translation|
          map_simple_wording(translation: translation)
        end
        plurals = locale_wording.plurals.map do |label, translations|
          map_compound_wording(label: label, translations: translations)
        end
        { singulars: singulars, plurals: plurals }
      end
    end
  end
end
