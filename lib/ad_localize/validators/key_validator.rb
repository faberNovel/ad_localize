module AdLocalize
  module Validators
    class KeyValidator
      # TODO : use in new csv parser
      def initialize
        @existing_key_for_label = {}
      end

      def has_warnings?(current_key)
        current_label = current_key.label
        existing_key = @existing_key_for_label[current_label]

        has_warnings = false

        unless existing_key.nil?
          existing_plural_key = existing_key.label == current_key.label && existing_key.plural? && current_key.singular?
          existing_singular_key = existing_key.label == current_key.label && existing_key.singular? && current_key.plural?
          is_same_key = existing_key.same_as?(key: current_key)
          LOGGER.warn "A plural value already exist for key '#{current_label}'. Remove duplicates." if existing_plural_key
          LOGGER.warn "A singular value already exist for key '#{current_label}'. Remove duplicates." if existing_singular_key
          LOGGER.warn "Some values already exist for key '#{current_label}'. Remove duplicates." if is_same_key
          has_warnings = is_same_key || existing_plural_key || existing_singular_key
        end

        @existing_key_for_label[current_label] = current_key

        has_warnings
      end
    end
  end
end