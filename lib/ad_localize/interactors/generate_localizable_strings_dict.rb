# frozen_string_literal: true
module AdLocalize
  module Interactors
    class GenerateLocalizableStringsDict < BaseGenerateFiles
      LOCALIZABLE_STRINGSDICT_FILENAME = "Localizable.stringsdict".freeze
      LOCALE_DIRECTORY_CONVENTION = "%{locale}.lproj".freeze

      def initialize(export_request:)
        super(serializer: Serializers::LocalizableStringsdictSerializer.new(export_request: export_request))
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.plurals.any? || locale_wording.adaptives.any?
      end

      def output_path(locale_wording:, export_request:)
        locale_directory_name = LOCALE_DIRECTORY_CONVENTION % { locale: locale_wording.locale }
        export_request.output_dir.join(locale_directory_name, LOCALIZABLE_STRINGSDICT_FILENAME)
      end
    end
  end
end
