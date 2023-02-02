# frozen_string_literal: true
module AdLocalize
  module Interactors
    class GenerateYAML < BaseGenerateFiles
      def initialize
        super(serializer: Serializers::YAMLSerializer.new)
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.singulars.any? || locale_wording.plurals.any?
      end

      def output_path(locale_wording:, export_request:)
        export_request.output_dir.join("#{locale_wording.locale}.yml")
      end
    end
  end
end
