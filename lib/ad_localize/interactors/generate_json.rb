module AdLocalize
  module Interactors
    class GenerateJSON < BaseGenerateFiles
      def initialize
        super(serializer: Serializers::JSONSerializer.new)
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.singulars.any? || locale_wording.plurals.any?
      end

      def output_path(locale_wording:, export_request:)
        export_request.output_dir.join("#{locale_wording.locale}.json")
      end
    end
  end
end
