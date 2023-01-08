module AdLocalize
  module Interactors
    class GenerateInfoPlist
      INFO_PLIST_FILENAME = "InfoPlist.strings".freeze
      LOCALE_DIRECTORY_CONVENTION = "%{locale}.lproj".freeze

      def initialize
        @serializer = Serializers::InfoPlistSerializer.new
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
        locale_wording.info_plists.any?
      end

      def prepare_output_path(locale_wording:, options:)
        locale_directory_name = LOCALE_DIRECTORY_CONVENTION % { locale: locale_wording.locale }
        output_dir = options[:platform_output_directory].join(locale_directory_name)
        @file_system_repository.create_directory(path: output_dir)
        output_dir.join(INFO_PLIST_FILENAME)
      end
    end
  end
end