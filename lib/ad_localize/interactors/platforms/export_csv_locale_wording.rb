module AdLocalize
  module Interactors
    module Platforms
      class ExportCSVLocaleWording
        def initialize
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(export_request:, platform_dir:)
          LOGGER.debug("Starting export CSV wording")
          @file_system_repository.create_directory(path: platform_dir)
          export_request.csv_paths.each_with_index { |csv_path, i|
            file = File.basename("localization_#{i}.csv")
            FileUtils.cp(csv_path, platform_dir.join(file.to_s))
          }
          LOGGER.debug("CSV wording export done !")
        end
      end
    end
  end
end