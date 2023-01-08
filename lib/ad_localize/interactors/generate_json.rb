module AdLocalize
  module Interactors
    class GenerateJSON
      def initialize
        @serializer = Serializers::JSONSerializer.new
        @file_system_repository = Repositories::FileSystemRepository.new
      end

      def call(wording:, options:)
        wording.each do |locale, locale_wording|
          path = prepare_output_path(locale_wording:, options:)
          LOGGER.debug("[#{locale}] Generating #{path.basename}")
          # TODO : fix JSON serializer
          content = @serializer.render(locale_wording: locale_wording)
          next if content[locale].blank?

          @file_system_repository.write(content:, path:)
          LOGGER.debug("#{path.basename} done !")
        end
      end

      private

      def prepare_output_path(locale_wording:, options:)
        output_dir = options[:platform_output_directory]
        @file_system_repository.create_directory(path: output_dir)
        output_dir.join("#{locale_wording.locale}.json")
      end
    end
  end
end
