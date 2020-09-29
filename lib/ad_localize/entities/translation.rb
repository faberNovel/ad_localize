module AdLocalize
  module Entities
    class Translation
      attr_reader(
        :locale,
        :key,
        :comment
      )

      attr_accessor(:value)

      def initialize(locale:, key:, value:, comment: nil)
        @locale = locale
        @key = key
        @value = value
        @comment = comment
      end
    end
  end
end