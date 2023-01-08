module AdLocalize
  module Mappers
    class LocaleWordingToHash
      def map(locale_wording:)
        singulars_hash = map_singulars(translations: locale_wording.singulars)
        plural_hash = map_plurals(translations: locale_wording.plurals)
        singulars_hash.merge(plural_hash)
      end

      private

      def inner_keys(label:)
        label.split('.')
      end

      def map_singulars(translations:)
        map_translations(translations:) do |inner_keys, value|
          recursive_hash(inner_keys, { inner_keys.pop => translation.value })
        end
      end
      
      def map_plurals(translations:)
        map_translations(translations:) do |inner_keys, value|
          recursive_hash(inner_keys, { translation.key.variant_name => translation.value })
        end
      end

      def map_translations(translations:)
        translations.each_with_object({}) do |translation, hash|
          inner_keys = inner_keys(label: translation.key.label)
          inner_keys_hash = yield(inner_keys, translation.value)
          hash.deep_merge(inner_keys_hash)
        end
      end

      def recursive_hash(array, h)
        if array.size.zero?
          h
        elsif array.size == 1
          { array.first => h }
        elsif array.size > 1
          { array.first => recursive_hash(array[1..-1], h, init) }
        end
      end
    end
  end
end
