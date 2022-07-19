module AdLocalize
  module Interactors
    module Platforms
      class ExportYAMLLocaleWording
        def initialize
          @yaml_serializer = Serializers::YAMLSerializer.new
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(export_wording_options:)
          locale = export_wording_options.locale
          wording = export_wording_options.wording
          platform_dir = export_wording_options.platform_directory
          LOGGER.debug("Starting export YAML wording for locale #{locale}")
          locale_wording = wording.translations_for(locale: locale)
          content = @yaml_serializer.render(locale_wording:locale_wording)
          return if content[locale].blank?

          @file_system_repository.create_directory(path: platform_dir)
          @file_system_repository.write(content: content, path: platform_dir.join("#{locale}.yml"))
          LOGGER.debug("#{locale}.yml done !")
        end

        def should_export_locale_by_locale?
          true
        end
      end
    end
  end
end