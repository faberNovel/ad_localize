# frozen_string_literal: true
module AdLocalize
  module Interactors
    class GenerateStrings < BaseGenerateFiles
      STRINGS_FILENAME = 'strings.xml'.freeze
      LOCALE_DIRECTORY_CONVENTION = "values".freeze

      def initialize
        super(serializer: Serializers::StringsSerializer.new)
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.singulars.any? || locale_wording.plurals.any?
      end

      def output_path(locale_wording:, export_request:)
        locale_dir = LOCALE_DIRECTORY_CONVENTION
        locale_dir += "-#{locale_wording.locale}" if !locale_wording.is_default
        export_request.output_dir.join(locale_dir, STRINGS_FILENAME)
      end
    end
  end
end
