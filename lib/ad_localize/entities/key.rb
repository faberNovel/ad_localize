module AdLocalize
  module Entities
    class Key
      def initialize(label:)
        @label = label
      end

      def plural_key
        @plural_key ||= compute_plural_key
      end

      def plural?
        plural_key.present?
      end

      def adaptive?
        adaptive_key.present?
      end

      def adaptive_key
        @adaptive_key ||= compute_adaptive_key
      end

      def info_plist?
        @label.match(Constant::INFO_PLIST_KEY_REGEXP).present?
      end

      def singular?
        !(plural? || adaptive? || info_plist?)
      end

      def label
        compute_label.strip
      end

      def raw_label
        @label
      end

      def same_as?(key:)
        raw_label == key.raw_label
      end

      private

      def compute_label
        if plural?
          @label.gsub(Constant::PLURAL_KEY_REGEXP, '')
        elsif adaptive?
          @label.gsub(Constant::ADAPTIVE_KEY_REGEXP, '')
        else
          @label
        end
      end

      def compute_plural_key
        match = @label.match(Constant::PLURAL_KEY_REGEXP)
        return unless match
        match.captures.first
      end

      def compute_adaptive_key
        match = @label.match(Constant::ADAPTIVE_KEY_REGEXP)
        return unless match
        match.captures.first
      end
    end
  end
end