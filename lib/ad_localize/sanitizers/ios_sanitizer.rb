# frozen_string_literal: true
module AdLocalize
  module Sanitizers
    class IOSSanitizer
      def sanitize(value:)
        return if value.blank?

        processed_value = value.gsub(/(?<!\\)\"/, "\\\"")
        # we should escape % sign when not used as formatting function (see: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html)
        processed_value = processed_value.gsub(/%(?!((\d+\$)?([a-zA-Z]|@)))/, '%%')
        processed_value
      end
    end
  end
end
