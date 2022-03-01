module AdLocalize
  module Serializers
    class StringsSerializer
      include WithTemplate

      def initialize
        @translation_mapper = Mappers::AndroidTranslationMapper.new
        @translation_group_mapper = Mappers::TranslationGroupMapper.new(translation_mapper: @translation_mapper)
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/android/strings.xml.erb"
      end

      def hash_binding(locale_wording:)
        {
          singulars: map_singulars(translations: locale_wording.singulars),
          plurals: map_plurals(plurals: locale_wording.plurals)
        }
      end

      def map_singulars(translations:)
        usable_translations = translations.select { |translation| translation.value != nil && !translation.value.empty? }
        usable_translations.map { |translation| @translation_mapper.map(translation: translation) }
      end

      def map_plurals(plurals:)
        plurals.map { |label, translations| 
          usable_translations = translations.select { |translation| translation.value != nil && !translation.value.empty? }
          @translation_group_mapper.map(label: label, translations: usable_translations) 
      }.select { |translation|
        !translation.translation_view_models.empty?
      }
      end
    end
  end
end