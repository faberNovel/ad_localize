# frozen_string_literal: true
module AdLocalize
  module Interactors
    class GenerateInfoPlist < BaseGenerateFiles
      INFO_PLIST_FILENAME = "InfoPlist.strings".freeze
      LOCALE_DIRECTORY_CONVENTION = "%{locale}.lproj".freeze

      def initialize
        super(serializer: Serializers::InfoPlistSerializer.new)
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.info_plists.any?
      end

      def output_path(locale_wording:, export_request:)
        locale_directory_name = LOCALE_DIRECTORY_CONVENTION % { locale: locale_wording.locale }
        export_request.output_dir.join(locale_directory_name, INFO_PLIST_FILENAME)
      end
    end
  end
end
