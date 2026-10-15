# frozen_string_literal: true
module AdLocalize
  module Sanitizers
    class ARBSanitizer
      # matches %%, %@, %1$@, %d, %02i, %1$.2f...
      FORMAT_SPECIFIER_REGEXP = /%%|%(?:(\d+)\$)?\d*(?:\.\d+)?([@dif])/
      PLACEHOLDER_TYPES = { '@' => 'String', 'd' => 'int', 'i' => 'int', 'f' => 'double' }.freeze

      def sanitize(value:)
        return if value.blank?

        convert(value: value).first
      end

      def placeholders(value:)
        return {} if value.blank?

        convert(value: value).last
      end

      private

      # Returns the ICU message and its placeholders ({ "p1" => "String" }).
      # Literal text is escaped as expected by gen-l10n when `use-escaping: true` is set
      def convert(value:)
        placeholders = {}
        unnumbered_index = 0
        message = +''
        text = unescape(value: value)
        last_position = 0
        text.scan(FORMAT_SPECIFIER_REGEXP) do
          match = Regexp.last_match
          message << escape(text: text[last_position...match.begin(0)])
          last_position = match.end(0)
          if match[0] == '%%'
            message << '%'
            next
          end

          index = match[1] || (unnumbered_index += 1).to_s
          name = "p#{index}"
          placeholders[name] = PLACEHOLDER_TYPES[match[2]]
          message << "{#{name}}"
        end
        message << escape(text: text[last_position..])
        [message, placeholders.sort_by { |name, _| name.delete_prefix('p').to_i }.to_h]
      end

      def unescape(value:)
        value.gsub('\\"', '"').gsub('\\n', "\n")
      end

      def escape(text:)
        text.gsub("'", "''").gsub(/[{}]+/) { |braces| "'#{braces}'" }
      end
    end
  end
end
