module AdLocalize
  module Interactors
    module Platforms
      class ExportYAMLLocaleWording
        def initialize
          @yaml_serializer = Serializers::YAMLSerializer.new
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(wording:, locale:, platform_dir:)
          LOGGER.debug("Starting export YAML wording for locale #{locale}")
          locale_wording = wording.translations_for(locale: locale)
          content = @yaml_serializer.render(locale_wording:locale_wording)
          return if content[locale].blank?

          @file_system_repository.create_directory(path: platform_dir)
          @file_system_repository.write(content: content, path: platform_dir.join("#{locale}.yml"))
          LOGGER.debug("#{locale}.yml done !")
        end
      end
    end
  end
end