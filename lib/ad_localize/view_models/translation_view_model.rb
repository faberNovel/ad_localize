module AdLocalize
  module ViewModels
    class TranslationViewModel
      attr_reader(
        :label,
        :key,
        :value,
        :comment
      )

      def initialize(label:, key:, value:, comment:)
        @label = label
        @key = key
        @value = value
        @comment = comment
      end
    end
  end
end