module AdLocalize
  module Serializers
    class InfoPlistSerializer < TemplatedSerializer
      INFO_PLIST_FILENAME = "InfoPlist.strings".freeze

      def initialize
        super(sanitizer: Sanitizers::IOSSanitizer.new) 
      end

      private

      def template_path
        TEMPLATES_DIRECTORY + "/ios/#{INFO_PLIST_FILENAME}.erb"
      end

      def variable_binding(locale_wording:)
        translations = locale_wording.info_plists.map { |translation| map_simple_wording(translation:) }
        { translations: translations }
      end
    end
  end
end
