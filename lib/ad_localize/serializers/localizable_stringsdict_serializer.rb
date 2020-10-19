module AdLocalize
  module Serializers
    class LocalizableStringsdictSerializer
      include WithTemplate

      LOCALIZABLE_STRINGSDICT_FILENAME = "Localizable.stringsdict".freeze

      def initialize
        @translation_mapper = Mappers::IOSTranslationMapper.new
        @translation_group_mapper = Mappers::TranslationGroupMapper.new(translation_mapper: @translation_mapper)
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/ios/#{LOCALIZABLE_STRINGSDICT_FILENAME}.erb"
      end

      def hash_binding(locale_wording:)
        {
          plurals: map_plurals(plurals: locale_wording.plurals),
          adaptives: map_adaptives(adaptives: locale_wording.adaptives)
        }
      end

      def map_plurals(plurals:)
        plurals.map { |label, translations| @translation_group_mapper.map(label: label, translations: translations) }
      end

      def map_adaptives(adaptives:)
        adaptives.map { |label, translations| @translation_group_mapper.map(label: label, translations: translations) }
      end
    end
  end
end