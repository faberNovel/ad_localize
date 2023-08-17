# frozen_string_literal: true
module AdLocalize
  module Sanitizers
    class IOSSanitizer
      def initialize(auto_escape_percent: false)
        @should_auto_escape_percent = auto_escape_percent
      end

      def sanitize(value:)
        return if value.blank?

        processed_value = value.gsub(/(?<!\\)\"/, "\\\"")
        if @should_auto_escape_percent
          # we should escape % sign when not used as formatting function (see: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html)
          processed_value = processed_value.gsub(/%(?!((\d+\$)?([a-zA-Z]|@)))/, '%%')
        end
        processed_value
      end
    end
  end
end
