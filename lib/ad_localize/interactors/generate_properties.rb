module AdLocalize
  module Interactors
    class GenerateProperties
      def initialize
        @serializer = Serializers::PropertiesSerializer.new
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
        locale_wording.singulars.any?
      end

      def prepare_output_path(locale_wording:, options:)
        output_dir = options[:platform_output_directory]
        @file_system_repository.create_directory(path: output_dir)
        output_dir.join("#{locale_wording.locale}.properties")
      end
    end
  end
end