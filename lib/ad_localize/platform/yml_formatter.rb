module AdLocalize::Platform
  class YmlFormatter < PlatformFormatter
    def platform
      :yml
    end

    def export(locale, data, export_extension = "yml", substitution_format = "yml")
      locale = locale.to_sym
      yml_data = build_platform_data_splitting_on_dots(locale, data)

      platform_dir.join("#{locale.to_s}.#{export_extension}").open("w") do |file|
        file.puts yml_data.to_yaml
      end

      AdLocalize::LOGGER.log(:debug, :green, "YAML [#{locale}] ---> DONE!")
    end

  end
end
