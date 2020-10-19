module AdLocalize
  module Mappers
    class TranslationMapper
      def map(translation:)
        ViewModels::TranslationViewModel.new(
          label: translation.key.label,
          key: key(translation: translation),
          value: sanitize_value(value: translation.value),
          comment: translation.comment
        )
      end

      protected

      def sanitize_value(value:)
        value
      end

      private

      def key(translation:)
        if translation.key.plural?
          translation.key.plural_key
        elsif translation.key.adaptive?
          translation.key.adaptive_key
        end
      end
    end
  end
end