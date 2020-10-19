module AdLocalize
  module Mappers
    class AndroidTranslationMapper < TranslationMapper
      private

      def sanitize_value(value:)
        return if value.blank?
        processedValue = value.gsub(/(?<!\\)'/, "\\\\'") # match ' unless there is a \ before
        processedValue = processedValue.gsub(/(?<!\\)\"/, "\\\"") # match " unless there is a \ before
        processedValue = processedValue.gsub(/(%(\d+\$)?@)/, '%\2s') # should match values like %1$s and %s
        processedValue = processedValue.gsub(/(%((\d+\$)?(\d+)?)i)/, '%\2d') # should match values like %i, %3$i, %01i, %1$02i
        processedValue = processedValue.gsub(/%(?!((\d+\$)?(s|(\d+)?d)))/, '%%') # negative lookahead: identifies when user really wants to display a %
        processedValue = processedValue.gsub("\\U", "\\u")
        "\"#{processedValue}\""
      end
    end
  end
end