module AdLocalize
  module Platforms
    class IOSPlatform
      def code
        :ios
      end

      # TODO (joanna_vigne 20/09/2020) gather everything related to platforms here
      def valid_translation_value?(value:)
      end

      def convert(translation_value:, formatting_convention:)
      end

      def sanitize(translation_value:)
      end

      def export_settings(locale_wording:)
        {
          info_plist: {
            filename: Constant::IOS_INFO_PLIST_EXPORT_FILENAME,
            binding: { translations: locale_wording.info_plists }
          },
          localizable_stringsdict: {
            filename: Constant::IOS_SINGULAR_EXPORT_FILENAME,
            binding: { plurals: locale_wording.plurals, adaptives: locale_wording.plurals }
          },
          localizable_strings: {
            filename: Constant::IOS_PLURAL_EXPORT_FILENAME,
            binding: { translations: locale_wording.singulars }
          }
        }
      end
    end
  end
end