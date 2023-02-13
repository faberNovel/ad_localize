# frozen_string_literal: true
module AdLocalize
  module Mappers
    class LocaleWordingToHash
      def map(locale_wording:)
        singulars_hash = map_singulars(simple_wordings: locale_wording.singulars.values)
        plural_hash = map_plurals(coumpound_wordings: locale_wording.plurals)
        locale_hash = singulars_hash.merge(plural_hash)
        { locale_wording.locale => locale_hash }
      end

      private

      def inner_keys(label:)
        label.split('.')
      end

      def map_singulars(simple_wordings:)
        map_translations(translations: simple_wordings) do |inner_keys, translation|
          dotted_key_to_hash(inner_keys, { inner_keys.pop => translation.value })
        end
      end

      def map_plurals(coumpound_wordings:)
        result = {}
        coumpound_wordings.each do |label, simple_wordings|
          variants_hash = map_translations(translations: simple_wordings) do |keys, translation|
            dotted_key_to_hash(keys, { translation.key.variant_name => translation.value })
          end
          result.deep_merge!(variants_hash)
        end
        result
      end

      def map_translations(translations:)
        translations.each_with_object({}) do |translation, hash|
          keys = inner_keys(label: translation.key.label)
          inner_keys_hash = yield(keys, translation)
          hash.deep_merge!(inner_keys_hash)
        end
      end

      def dotted_key_to_hash(array, h)
        if array.size.zero?
          h
        elsif array.size == 1
          { array.first => h }
        elsif array.size > 1
          { array.first => dotted_key_to_hash(array[1..-1], h) }
        end
      end
    end
  end
end
