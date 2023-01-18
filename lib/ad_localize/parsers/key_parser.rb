module AdLocalize
  module Parsers
    class KeyParser
      PLURAL_KEY_REGEXP = /\#\#\{([A-Za-z]+)\}/.freeze
      ADAPTIVE_KEY_REGEXP = /\#\#\{(\d+)\}/.freeze
      # see https://developer.apple.com/documentation/bundleresources/information_property_list
      INFO_PLIST_KEY_REGEXP = /(NS.+UsageDescription)|(CF.+Name)|NFCReaderUsageDescription/.freeze

      def call(raw_key:)
        type = compute_type(raw_key:)
        label = compute_label(raw_key:, type:)
        variant_name = compute_variant_name(raw_key:, type:)
        Entities::Key.new(id: raw_key, label:, type:, variant_name:)
      end

      def plural?(raw_key:)
        !raw_key.match(PLURAL_KEY_REGEXP).nil?
      end

      def adaptive?(raw_key:)
        !raw_key.match(ADAPTIVE_KEY_REGEXP).nil?
      end

      def info_plist?(raw_key:)
        !raw_key.match(INFO_PLIST_KEY_REGEXP).nil?
      end

      def compute_type(raw_key:)
        if plural?(raw_key:)
          Entities::WordingType::PLURAL
        elsif adaptive?(raw_key:)
          Entities::WordingType::ADAPTIVE
        elsif info_plist?(raw_key:)
          Entities::WordingType::INFO_PLIST
        else
          Entities::WordingType::SINGULAR
        end
      end

      def compute_label(raw_key:, type:)
        case type
        when Entities::WordingType::PLURAL
          raw_key.gsub(PLURAL_KEY_REGEXP, '')
        when Entities::WordingType::ADAPTIVE
          raw_key.gsub(ADAPTIVE_KEY_REGEXP, '')
        else
          raw_key
        end
      end

      def compute_variant_name(raw_key:, type:)
        case type
        when Entities::WordingType::PLURAL
          raw_key.match(PLURAL_KEY_REGEXP)&.captures&.first
        when Entities::WordingType::ADAPTIVE
          raw_key.match(ADAPTIVE_KEY_REGEXP)&.captures&.first
        end
      end
    end
  end
end
