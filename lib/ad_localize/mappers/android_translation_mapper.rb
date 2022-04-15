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
        hasFormatting = processedValue.match(/(%(\d+\$)?@)/)
        processedValue = processedValue.gsub(/(%(\d+\$)?@)/, '%\2s') # should match values like %1$s and %s
        hasFormatting = hasFormatting || processedValue.match(/(%((\d+\$)?(\d+)?)i)/)
        processedValue = processedValue.gsub(/(%((\d+\$)?(\d+)?)i)/, '%\2d') # should match values like %i, %3$i, %01i, %1$02i
        # On Android, '%' must be escaped with a second '%' if and only if the string has at least one formatting pattern. In this specific case, 
        # a Java formatting method will be used which interprets every non escaped '%' as the start of a formatting pattern.
        if hasFormatting 
          processedValue = processedValue.gsub(/%(?!((\d+\$)?(s|(\d+)?d)))/, '%%') # negative lookahead: identifies when user really wants to display a %
        else
          processedValue = processedValue.gsub(/%(?!((\d+\$)?(s|(\d+)?d)))/, '%') # negative lookahead: identifies when user really wants to display a %
        end
        processedValue = processedValue.gsub("\\U", "\\u")
        processedValue = processedValue.gsub(/&(?!((#\d+)|(\w+));)/, '&#38;')
        processedValue = processedValue.gsub(/&/) { |match| match.replace('\&') }
        "\"#{processedValue}\""
      end
    end
  end
end