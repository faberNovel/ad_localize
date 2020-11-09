module AdLocalize
  module Mappers
    class AndroidTranslationMapper < TranslationMapper
      private

      def sanitize_value(value:)
        return if value.blank?
        processedValue = value.gsub(/(?<!\\)'/, '&#39;') # match ' unless there is a \ before
        processedValue = processedValue.gsub(/(?<!\\)\"/, '&#34;') # match " unless there is a \ before
        processedValue = processedValue.gsub(">", '&gt;')
        processedValue = processedValue.gsub("<", '&lt;')
        processedValue = processedValue.gsub(/(%(\d+\$)?@)/, '%\2s') # should match values like %1$s and %s
        processedValue = processedValue.gsub(/(%((\d+\$)?(\d+)?)i)/, '%\2d') # should match values like %i, %3$i, %01i, %1$02i
        processedValue = processedValue.gsub(/%(?!((\d+\$)?(s|(\d+)?d)))/, '&#37;') # negative lookahead: identifies when user really wants to display a %
        processedValue = processedValue.gsub("\\U", "\\u")
        processedValue = processedValue.gsub(/&(?!((#\d+)|(\w+));)/, '&#38;')
        processedValue = processedValue.gsub(/&/) { |match| match.replace('\&') }
        "\"#{processedValue}\""
      end
    end
  end
end