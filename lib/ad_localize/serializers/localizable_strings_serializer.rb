module AdLocalize
  module Serializers
    class LocalizableStringsSerializer
      include WithTemplate

      LOCALIZABLE_STRINGS_FILENAME = "Localizable.strings".freeze

      def initialize
        @translation_mapper = Mappers::IOSTranslationMapper.new
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/ios/#{LOCALIZABLE_STRINGS_FILENAME}.erb"
      end

      def hash_binding(locale_wording:)
        { translations: map_translations(translations: locale_wording.singulars) }
      end

      def map_translations(translations:)
        translations.map { |translation| @translation_mapper.map(translation: translation) }
      end
    end
  end
end