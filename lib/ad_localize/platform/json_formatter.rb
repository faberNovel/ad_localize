module AdLocalize::Platform
  class JsonFormatter < PlatformFormatter
    def platform
      :json
    end

    def export(locale, data, export_extension = "json", substitution_format = "react")
      locale = locale.to_sym
      json_data = data.each_with_object({}) do |(key, wording), hash_acc|
        hash_acc[locale.to_s] = {} unless hash_acc.key? locale.to_s
        keys = key.to_s.split('.')
        hash = hash_acc[locale.to_s]
        keys.each_with_index do |inner_key, index|
          if index === keys.count - 1
            fill_hash(wording, locale, hash, inner_key)
          else
            if hash[inner_key].nil?
              hash[inner_key] = {}
            end
            hash = hash[inner_key]
          end
        end
      end

      platform_dir.join("#{locale.to_s}.#{export_extension}").open("w") do |file|
        file.puts json_data.to_json
      end

      AdLocalize::LOGGER.log(:debug, :green, "JSON [#{locale}] ---> DONE!")
    end

    protected

    def fill_hash(wording, locale, hash, key)
      if wording.dig(locale)&.key? :singular
        value = wording.dig(locale, :singular)
        hash[key.to_s] = value
      end
      if wording.dig(locale)&.key? :plural
        hash[key.to_s] = {}
        wording.dig(locale, :plural).each do |plural_type, plural_text|
          value = plural_text
          hash[key.to_s][plural_type.to_s] = value
        end
      end
    end
  end
end
