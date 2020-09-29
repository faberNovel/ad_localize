module AdLocalize
  module Platforms
    class AndroidPlatform
      def code
        :android
      end

      def export_settings(locale_wording:)
        {
          strings: {
            filename: Constant::ANDROID_EXPORT_FILENAME,
            binding: { singulars: locale_wording.singulars, plurals: locale_wording.plurals }
          }
        }
      end

      def convert(translation_value:, formatting_convention:)

      end

      def sanitize(translation_value:)

      end
    end
  end
end