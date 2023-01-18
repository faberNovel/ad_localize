module AdLocalize
    module Sanitizers
        class IOSSanitizer
            def sanitize(value:)
                return if value.blank?
                value.gsub(/(?<!\\)\"/, "\\\"")
            end
        end
    end
end
