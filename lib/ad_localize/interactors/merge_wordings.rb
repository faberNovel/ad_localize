module AdLocalize
  module Interactors
    class MergeWordings
      REPLACE_MERGE_POLICY = 'replace'.freeze
      KEEP_MERGE_POLICY = 'keep'.freeze
      MERGE_POLICIES = [KEEP_MERGE_POLICY, REPLACE_MERGE_POLICY]

      def self.valid_policy?(policy:)
        MERGE_POLICIES.include?(policy)
      end

      def call(wordings:, merge_policy:)
        if wordings.size == 1
          wordings.first
        elsif wordings.size > 1
          LOGGER.debug("Merge wordings before processing")
          merge_many(wordings: wordings, merge_policy: merge_policy)
        end
      end

      private

      def merge_simple_wordings(reference_list:, new_list:, merge_policy:)
        new_list.each_with_index do |new_translation, index|
          translation_reference = reference_list[index]
          if translation_reference.nil?
            reference_list.append(new_translation)
          elsif merge_policy.replace?
            translation_reference.value = new_translation.value
          end
        end
      end

      def merge_compound_wordings(reference_hash:, new_hash:, merge_policy:)
        new_hash.each do |new_label, new_list|
          if reference_hash[new_label].nil?
            reference_hash[new_label] = new_list
          elsif merge_policy.replace?
            merge_simple_wordings(reference_list: reference_hash[new_label], new_list:, merge_policy:)
          end
        end
      end

      def merge_many(wordings:, merge_policy:)
        wording_reference = wordings.first
        wordings[1..-1].each do |wording|
          wording.each do |locale, locale_wording|
            reference = wording_reference[locale]
            merge_simple_wordings(reference_list: reference.singulars, new_list: locale_wording.singulars, merge_policy:)
            merge_simple_wordings(reference_list: reference.info_plists, new_list: locale_wording.info_plists, merge_policy:)
            merge_compound_wordings(reference_hash: reference.plurals, new_hash: locale_wording.plurals, merge_policy:)
            merge_compound_wordings(reference_hash: reference.adaptives, new_hash: locale_wording.adaptives, merge_policy:)
          end
        end
        wording_reference
      end
    end
  end
end
