module AdLocalize
  module Interactors
    module Platforms
      class ExportCSVLocaleWording
        def initialize
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(export_wording_options:)
          LOGGER.debug("Starting export CSV wording")
          @file_system_repository.create_directory(path: export_wording_options.platform_output_directory)
          export_wording_options.csv_paths.each_with_index do |csv_path, i|
            file = File.basename("localization_#{i}.csv")
            output_path = export_wording_options.platform_output_directory.join(file.to_s)
            FileUtils.cp(csv_path, output_path)
          end
          LOGGER.debug("CSV wording export done !")
        end
      end
    end
  end
end