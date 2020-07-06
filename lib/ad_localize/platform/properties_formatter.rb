module AdLocalize::Platform
  class PropertiesFormatter < PlatformFormatter
    def platform
      :properties
    end

    def export(locale, data, export_extension = "properties", substitution_format = "java")
      locale = locale.to_sym

      platform_dir.join("#{locale.to_s}.#{export_extension}").open("a") do |file|
        data.each do |key, wording|
          singular_wording = wording.dig(locale, AdLocalize::Constant::SINGULAR_KEY_SYMBOL)
          unless singular_wording.blank?
            line = "#{key}=#{singular_wording}"
            line << "\n"
            file.puts line
          end
        end
      end

      AdLocalize::LOGGER.log(:debug, :green, "Properties [#{locale}] ---> DONE!")
    end

  end
end
