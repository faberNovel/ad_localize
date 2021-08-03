module AdLocalize
  module Interactors
    module Platforms
      class ExportJSONLocaleWording
        def initialize
          @json_serializer = Serializers::JSONSerializer.new
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(wording:, locale:, platform_dir:)
          LOGGER.debug("Starting export JSON wording for locale #{locale}")
          locale_wording = wording.translations_for(locale: locale)
          content = @json_serializer.render(locale_wording: locale_wording)
          return if content[locale].blank?

          @file_system_repository.create_directory(path: platform_dir)
          @file_system_repository.write(content: content, path: platform_dir.join("#{locale}.json"))
          LOGGER.debug("#{locale}.json done !")
        end

        def should_export_locale_by_locale?
          true
        end
      end
    end
  end
end