module AdLocalize
  module Serializers
    class InfoPlistSerializer
      include WithTemplate

      INFO_PLIST_FILENAME = "InfoPlist.strings".freeze

      def initialize
        @translation_mapper = Mappers::IOSTranslationMapper.new
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/ios/#{INFO_PLIST_FILENAME}.erb"
      end

      def hash_binding(locale_wording:)
        { translations: map_translations(translations: locale_wording.info_plists) }
      end

      def map_translations(translations:)
        translations.map { |translation| @translation_mapper.map(translation: translation) }
      end
    end
  end
end