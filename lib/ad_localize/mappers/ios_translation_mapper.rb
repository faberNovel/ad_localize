module AdLocalize
  module Mappers
    class IOSTranslationMapper < TranslationMapper
      private

      def sanitize_value(value:)
        return if value.blank?
        value.gsub(/(?<!\\)\"/, "\\\"")
      end
    end
  end
end