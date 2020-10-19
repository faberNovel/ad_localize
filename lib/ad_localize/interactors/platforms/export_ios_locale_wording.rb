module AdLocalize
  module Interactors
    module Platforms
      class ExportIOSLocaleWording
        INFO_PLIST_FILENAME = "InfoPlist.strings".freeze
        LOCALIZABLE_STRINGS_FILENAME = "Localizable.strings".freeze
        LOCALIZABLE_STRINGSDICT_FILENAME = "Localizable.stringsdict".freeze
        LOCALE_DIRECTORY_CONVENTION = "%{locale}.lproj".freeze

        def initialize
          @info_plist_serializer = Serializers::InfoPlistSerializer.new
          @localizable_strings_serializer = Serializers::LocalizableStringsSerializer.new
          @localizable_stringsdict_serializer = Serializers::LocalizableStringsdictSerializer.new
          @file_system_repository = Repositories::FileSystemRepository.new
        end

        def call(wording:, locale:, platform_dir:)
          LOGGER.debug("Starting export iOS wording for locale #{locale}")
          locale_wording = wording.translations_for(locale: locale)
          return unless has_ios_wording?(locale_wording: locale_wording)

          output_dir = platform_dir.join(LOCALE_DIRECTORY_CONVENTION % { locale: locale })
          @file_system_repository.create_directory(path: output_dir)

          export_info_plist(locale_wording: locale_wording, output_dir: output_dir)
          export_localizable_strings(locale_wording: locale_wording, output_dir: output_dir)
          export_localizable_stringsdict(locale_wording: locale_wording, output_dir: output_dir)
        end

        private

        def has_ios_wording?(locale_wording:)
          locale_wording.has_info_plist_keys? ||
            locale_wording.has_singular_keys? ||
            locale_wording.has_plural_keys? ||
            locale_wording.has_adaptive_keys?
        end

        def export_info_plist(locale_wording:, output_dir:)
          return unless locale_wording.has_info_plist_keys?
          content = @info_plist_serializer.render(locale_wording: locale_wording)
          @file_system_repository.write(content: content, path: output_dir.join(INFO_PLIST_FILENAME))
          LOGGER.debug("#{INFO_PLIST_FILENAME} done !")
        end

        def export_localizable_strings(locale_wording:, output_dir:)
          return unless locale_wording.has_singular_keys?
          content = @localizable_strings_serializer.render(locale_wording: locale_wording)
          @file_system_repository.write(content: content, path: output_dir.join(LOCALIZABLE_STRINGS_FILENAME))
          LOGGER.debug("#{LOCALIZABLE_STRINGS_FILENAME} done !")
        end

        def export_localizable_stringsdict(locale_wording:, output_dir:)
          return unless locale_wording.has_plural_keys? || locale_wording.has_adaptive_keys?
          content = @localizable_stringsdict_serializer.render(locale_wording: locale_wording)
          @file_system_repository.write(content: content, path: output_dir.join(LOCALIZABLE_STRINGSDICT_FILENAME))
          LOGGER.debug("#{LOCALIZABLE_STRINGSDICT_FILENAME} done !")
        end
      end
    end
  end
end