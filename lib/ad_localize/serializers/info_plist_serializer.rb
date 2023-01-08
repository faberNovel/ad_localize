module AdLocalize
  module Serializers
    class InfoPlistSerializer
      include WithTemplate

      INFO_PLIST_FILENAME = "InfoPlist.strings".freeze

      private

      def template_path
        TEMPLATES_DIRECTORY + "/ios/#{INFO_PLIST_FILENAME}.erb"
      end

      def variable_binding(locale_wording:)
        translations = locale_wording.info_plists.map { |translation| translation_to_binding(translation:) }
        { translations: translations }
      end

      def translation_to_binding(translation:)
        SimpleWordingViewModel.new(
          label: translation.key.label,
          value: sanitize_value(value: translation.value),
          comment: translation.comment
        )
      end

      def sanitize_value(value:)
        return if value.nil? || value.strip.empty?
        value.gsub(/(?<!\\)\"/, "\\\"")
      end
    end
  end
end
