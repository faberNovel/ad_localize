# frozen_string_literal: true
module AdLocalize
  module Interactors
    class GenerateProperties < BaseGenerateFiles
      def initialize
        super(serializer: Serializers::PropertiesSerializer.new)
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.singulars.any?
      end

      def output_path(locale_wording:, export_request:)
        export_request.output_dir.join("#{locale_wording.locale}.properties")
      end
    end
  end
end
