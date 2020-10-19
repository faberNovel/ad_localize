module AdLocalize
  module ViewModels
    class TranslationGroupViewModel
      attr_reader(
        :label,
        :translation_view_models
      )

      def initialize(label:, translation_view_models:)
        @label = label
        @translation_view_models = translation_view_models
      end
    end
  end
end