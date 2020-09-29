module AdLocalize
  module Mappers
    class LocaleWordingToHash
      def map(locale_wording:)
        result = locale_wording.translations.each_with_object({}) do |translation, hash|
          inner_keys = translation.key.label.split('.')
          inner_keys.each_with_index do |inner_key, index|
            if index === inner_keys.count - 1
              if translation.key.plural?
                hash[translation.key.label] = {} unless hash.key? translation.key.label
                hash[translation.key.label][translation.key.plural_key] = translation.value
              else
                hash[inner_key.to_s] = translation.value
              end
            else
              hash[inner_key] = {} if hash[inner_key].nil?
              hash = hash[inner_key]
            end
          end
        end
        { locale_wording.locale => result }
      end
    end
  end
end