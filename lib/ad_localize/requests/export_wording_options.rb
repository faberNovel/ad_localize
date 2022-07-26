module AdLocalize
    module Requests
      class ExportWordingOptions
        def initialize(wording:, platform_output_directory:, locales: [], bypass_empty_values: false, csv_paths: [])
            @wording = wording
            @locales = locales
            @platform_output_directory = platform_output_directory
            @bypass_empty_values = bypass_empty_values
            @csv_paths = csv_paths
        end
        
        attr_reader(
            :wording,
            :platform_output_directory,
            :bypass_empty_values,
            :locales
        )

        attr_accessor(
            :csv_paths
        )
      end
    end
end