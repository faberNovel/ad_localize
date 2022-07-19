module AdLocalize
  module Interactors
    module Platforms
      class ExportAndroidLocaleWording
        STRINGS_FILENAME = 'strings.xml'.freeze
        LOCALE_DIRECTORY_CONVENTION = "values%{locale_suffix}".freeze

        def initialize
          @strings_serializer = Serializers::StringsSerializer.new
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(export_wording_options:)
          locale = export_wording_options.locale
          wording = export_wording_options.wording
          platform_dir = export_wording_options.platform_directory
          LOGGER.debug("Starting export Android wording for locale #{locale}")
          locale_wording = wording.translations_for(locale: locale)
          return unless has_android_wording?(locale_wording: locale_wording)

          output_dir = compute_output_dir(wording: wording, locale: locale, platform_dir: platform_dir)
          @file_system_repository.create_directory(path: output_dir)

          content = @strings_serializer.render(locale_wording: locale_wording)
          @file_system_repository.write(content: content, path: output_dir.join(STRINGS_FILENAME))
          LOGGER.debug("#{STRINGS_FILENAME} done !")
        end

        def should_export_locale_by_locale?
          true
        end

        private

        def has_android_wording?(locale_wording:)
          locale_wording.has_singular_keys? || locale_wording.has_plural_keys?
        end

        def compute_output_dir(wording:, locale:, platform_dir:)
          locale_suffix = wording.default_locale?(locale: locale) ? '' : "-#{locale}"
          platform_dir.join(LOCALE_DIRECTORY_CONVENTION % { locale_suffix: locale_suffix })
        end
      end
    end
  end
end