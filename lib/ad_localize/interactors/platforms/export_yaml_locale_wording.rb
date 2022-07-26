module AdLocalize
  module Interactors
    module Platforms
      class ExportYAMLLocaleWording
        def initialize
          @yaml_serializer = Serializers::YAMLSerializer.new
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(export_wording_options:)
          output_dir = export_wording_options.platform_output_directory

          export_wording_options.locales.each do |locale|
            LOGGER.debug("Starting export YAML wording for locale #{locale}")
            locale_wording = export_wording_options.wording.translations_for(locale: locale)
            content = @yaml_serializer.render(locale_wording: locale_wording)
            next if content[locale].blank?

            @file_system_repository.create_directory(path: output_dir)
            @file_system_repository.write(content: content, path: output_dir.join("#{locale}.yml"))
            LOGGER.debug("#{locale}.yml done !")
          end
        end
      end
    end
  end
end