require 'yaml'
require_relative 'platform_formatter'

module Internationalize::Platform
  class YmlFormatter < PlatformFormatter
    def platform
      :yml
    end

    def export(locale, data, export_extension="yml", substitution_format="yml")
      super(locale, data, export_extension, substitution_format) do |yml_data, file|
        file.puts yml_data.to_yaml
      end
    end

    protected
    def ios_converter(value)
      value.gsub(/(%(?!)?(\d+\$)?[@isd])/, "VARIABLE_TO_SET")
    end
  end
end