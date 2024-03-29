# frozen_string_literal: true
module AdLocalize
  module Interactors
    class BaseGenerateFiles
      def initialize(serializer:)
        @serializer = serializer
        raise MissingArgument.new('Missing Serializer') unless serializer

        @file_system_repository = Repositories::FileSystemRepository.new
      end

      def call(wording:, export_request:)
        @serializer.configure(export_request: export_request) if @serializer.respond_to?(:configure)
        wording.each do |locale, locale_wording|
          next unless has_wording?(locale_wording: locale_wording)

          path = output_path(locale_wording: locale_wording, export_request: export_request)
          filename = path.basename
          LOGGER.debug("[#{locale}] Generating #{filename}")
          @file_system_repository.create_directory(path: path.dirname)
          content = @serializer.render(locale_wording: locale_wording)
          @file_system_repository.write(content: content, path: path)
          LOGGER.debug("[#{locale}] #{filename} done !")
        end
      end

      protected

      def has_wording?(locale_wording:)
        raise 'override me!'
      end

      def output_path(locale_wording:, export_request:)
        raise 'override me!'
      end
    end
  end
end
