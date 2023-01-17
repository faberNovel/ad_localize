module AdLocalize
  module Interactors
    class GenerateLocalizableStrings < BaseGenerateFiles
      LOCALIZABLE_STRINGS_FILENAME = "Localizable.strings".freeze
      LOCALE_DIRECTORY_CONVENTION = "%{locale}.lproj".freeze

      def initialize
        super(serializer: Serializers::LocalizableStringsSerializer.new)
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.singulars.any?
      end

      def output_path(locale_wording:, export_request:)
        locale_directory_name = LOCALE_DIRECTORY_CONVENTION % { locale: locale_wording.locale }
        export_request.output_dir.join(locale_directory_name, LOCALIZABLE_STRINGS_FILENAME)
      end
    end
  end
end
