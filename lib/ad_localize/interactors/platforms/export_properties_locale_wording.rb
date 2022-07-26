module AdLocalize
  module Interactors
    module Platforms
      class ExportPropertiesLocaleWording
        def initialize
          @properties_serializer = Serializers::PropertiesSerializer.new
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(export_wording_options:)
          export_wording_options.locales.each do |locale|
            LOGGER.debug("Starting export Properties wording for locale #{locale}")
            locale_wording = export_wording_options.wording.translations_for(locale: locale)
            return unless has_properties_wording?(locale_wording: locale_wording)

            content = @properties_serializer.render(locale_wording: locale_wording)
            @file_system_repository.create_directory(path: export_wording_options.platform_output_directory)
            output_path = export_wording_options.platform_output_directory.join("#{locale}.properties")
            @file_system_repository.write(content: content, path: output_path)
            LOGGER.debug("#{locale}.properties done !")
          end
        end

        private

        def has_properties_wording?(locale_wording:)
          locale_wording.has_singular_keys?
        end
      end
    end
  end
end