# frozen_string_literal: true
module AdLocalize
  module Sanitizers
    class PassThroughSanitizer
      def sanitize(value:)
        value
      end
    end
  end
end
