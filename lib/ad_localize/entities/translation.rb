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

      def ==(o)
        o.class == self.class &&
        o.locale == locale &&
        o.key == key &&
        o.value == value &&
        o.comment == comment
      end

      def has_value?
        value.present?
      end
    end
  end
end