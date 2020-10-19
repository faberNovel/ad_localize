module AdLocalize
  module Mappers
    class TranslationGroupMapper
      def initialize(translation_mapper: TranslationMapper.new)
        @translation_mapper = translation_mapper
      end

      def map(label:, translations:)
        translation_view_models = translations.map { |translation| @translation_mapper.map(translation: translation) }
        ViewModels::TranslationGroupViewModel.new(label: label, translation_view_models: translation_view_models)
      end
    end
  end
end