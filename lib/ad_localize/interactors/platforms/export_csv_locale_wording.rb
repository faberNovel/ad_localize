module AdLocalize
  module Interactors
    module Platforms
      class ExportCSVLocaleWording
        # TODO delete : no interest. This class just copies each csv to another location
        def initialize
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(wording:, options:)
          LOGGER.debug("Starting export CSV wording")
          output_dir = options[:platform_output_directory]
          @file_system_repository.create_directory(path: output_dir)
          options[:csv_paths].each_with_index do |csv_path, i|
            file = File.basename("localization_#{i}.csv")
            FileUtils.cp(csv_path, output_dir.join(file.to_s))
          end
          LOGGER.debug("CSV wording export done !")
        end
      end
    end
  end
end