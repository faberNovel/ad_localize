# frozen_string_literal: true
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
        plurals = locale_wording.plurals.map do |label, translations|
          map_compound_wording(label: label, translations: translations)
        end
        adaptives = locale_wording.adaptives.map do |label, translations|
          map_compound_wording(label: label, translations: translations)
        end
        { plurals: plurals, adaptives: adaptives }
      end
    end
  end
end
