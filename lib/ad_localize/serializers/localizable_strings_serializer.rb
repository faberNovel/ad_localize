# frozen_string_literal: true
module AdLocalize
  module Serializers
    class LocalizableStringsSerializer < TemplatedSerializer
      LOCALIZABLE_STRINGS_FILENAME = "Localizable.strings".freeze

      def initialize
        super(sanitizer: Sanitizers::IOSSanitizer.new)
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/ios/#{LOCALIZABLE_STRINGS_FILENAME}.erb"
      end

      def variable_binding(locale_wording:)
        translations = locale_wording.singulars.map do |translation|
          map_simple_wording(translation: translation)
        end
        { translations: translations }
      end
    end
  end
end
