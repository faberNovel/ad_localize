module AdLocalize
  module Interactors
    class GenerateStrings
      STRINGS_FILENAME = 'strings.xml'.freeze
      LOCALE_DIRECTORY_CONVENTION = "values%{locale_suffix}".freeze

      def initialize
        @serializer = Serializers::StringsSerializer.new
        @file_system_repository = Repositories::FileSystemRepository.new
      end

      def call(wording:, options:)
        wording.each do |locale, locale_wording|
          next unless has_wording?(locale_wording:)
          
          path = prepare_output_path(locale_wording:, options:)
          filename = path.basename
          LOGGER.debug("[#{locale}] Generating #{filename}")
          content = @serializer.render(locale_wording:)
          @file_system_repository.write(content:, path:)
          LOGGER.debug("[#{locale}] #{filename} done !")
        end
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.singulars.any? || locale_wording.plurals.any?
      end

      def prepare_output_path(locale_wording:, options:)
        platform_dir = options[:platform_output_directory]
        locale_suffix = locale_wording.is_default ? '' : "-#{locale_wording.locale}"
        output_dir = platform_dir.join(LOCALE_DIRECTORY_CONVENTION % { locale_suffix: locale_suffix })
        @file_system_repository.create_directory(path: output_dir)
        output_dir.join(STRINGS_FILENAME)
      end
    end
  end
end
