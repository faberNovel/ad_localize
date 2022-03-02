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
        translations.select(&:has_value?).map { |translation| @translation_mapper.map(translation: translation) }
      end

      def map_plurals(plurals:)
        plurals
        .map { |label, translations| @translation_group_mapper.map(label: label, translations: translations.select(&:has_value?)) }
        .select(&:has_translations?)
      end
    end
  end
end