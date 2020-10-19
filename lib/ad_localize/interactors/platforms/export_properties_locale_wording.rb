module AdLocalize
  module Interactors
    module Platforms
      class ExportPropertiesLocaleWording
        def initialize
          @properties_serializer = Serializers::PropertiesSerializer.new
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(wording:, locale:, platform_dir:)
          LOGGER.debug("Starting export Properties wording for locale #{locale}")
          locale_wording = wording.translations_for(locale: locale)
          return unless has_properties_wording?(locale_wording: locale_wording)

          content = @properties_serializer.render(locale_wording: locale_wording)
          @file_system_repository.create_directory(path: platform_dir)
          @file_system_repository.write(content: content, path: platform_dir.join("#{locale}.properties"))
          LOGGER.debug("#{locale}.properties done !")
        end

        private

        def has_properties_wording?(locale_wording:)
          locale_wording.has_singular_keys?
        end
      end
    end
  end
end