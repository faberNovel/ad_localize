module AdLocalize
    module Requests
      class ExportWordingOptions
        def initialize(wording:, platform_directory:, locale: nil, bypass_empty_values: false, csv_paths: [])
            @wording = wording
            @locale = locale
            @platform_directory = platform_directory
            @bypass_empty_values = bypass_empty_values
            @csv_paths = csv_paths
        end
        
        attr_reader(
            :wording,
            :platform_directory,
            :bypass_empty_values,
        )

        attr_accessor(
            :locale,
            :csv_paths,
        )
      end
    end
end