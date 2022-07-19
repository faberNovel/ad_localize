module AdLocalize
  module Interactors
    module Platforms
      class ExportCSVLocaleWording
        def initialize
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(export_wording_options:)
          locale = export_wording_options.locale
          wording = export_wording_options.wording
          platform_dir = export_wording_options.platform_directory
          LOGGER.debug("Starting export CSV wording")
          @file_system_repository.create_directory(path: platform_dir)
          export_wording_options.csv_paths.each_with_index do |csv_path, i|
            file = File.basename("localization_#{i}.csv")
            FileUtils.cp(csv_path, platform_dir.join(file.to_s))
          end
          LOGGER.debug("CSV wording export done !")
        end

        def should_export_locale_by_locale?
          false
        end
      end
    end
  end
end