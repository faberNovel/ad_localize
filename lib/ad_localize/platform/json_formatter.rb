module AdLocalize::Platform
  class JsonFormatter < PlatformFormatter
    def platform
      :json
    end

    def export(locale, data, export_extension = "json", substitution_format = "react")
      locale = locale.to_sym
      json_data = build_platform_data_splitting_on_dots(locale, data)
      platform_dir.join("#{locale.to_s}.#{export_extension}").open("w") do |file|
        file.puts json_data.to_json
      end

      AdLocalize::LOGGER.log(:debug, :green, "JSON [#{locale}] ---> DONE!")
    end
  end
end
