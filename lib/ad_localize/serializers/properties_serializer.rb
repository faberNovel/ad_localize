module AdLocalize
  module Serializers
    class PropertiesSerializer
      include WithTemplate

      def initialize
        @translation_mapper = Mappers::TranslationMapper.new
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/properties/template.properties.erb"
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