module AdLocalize::Platform
  class JsonFormatter < PlatformFormatter
    def platform
      :json
    end

    def export(locale, data, export_extension = "json", substitution_format = "angular")
      super(locale, data, export_extension, substitution_format) do |json_data, file|
        file.puts json_data.to_json
      end
    end

    protected
    def ios_converter(value)
      value.gsub(/(%(?!)?(\d+\$)?[@isd])/, "VARIABLE_TO_SET")
    end
  end
end