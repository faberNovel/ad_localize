module AdLocalize
  module Interactors
    class MergeWordings
      def call(wordings:, merge_policy:)
        if wordings.size == 1
          wordings.first
        elsif wordings.size > 1
          merge_many(wordings: wordings, merge_policy: merge_policy)
        end
      end

      private

      def merge_many(wordings:, merge_policy:)
        merge_policy_is_replace = merge_policy == Constant::REPLACE_MERGE_POLICY
        final_wording = wordings.first
        wordings[1..-1].each do |wording|
          wording.locale_wordings.each do |locale_wording|
            locale_wording_reference = final_wording.translations_for(locale: locale_wording.locale)
            locale_wording.translations.each do |translation|
              translation_reference = locale_wording_reference.translation_for(key: translation.key)
              if translation_reference.present? && merge_policy_is_replace
                translation_reference.value = translation.value
              else
                locale_wording_reference.add_translation(translation: translation)
              end
            end
          end
        end
        final_wording
      end
    end
  end
end