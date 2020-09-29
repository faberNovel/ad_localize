module AdLocalize
  module Interactors
    class ExportWording
      def initialize(builder: nil, output_strategy: nil)
        @builder = builder.presence || Builders::WordingBuilder.new
        @output_strategy = output_strategy.presence || Outputs::FSStrategy.new
      end

      def call(export_request:, wording:)
        locales = export_request.locales.size.zero? ? wording.locales : wording.locales & export_request.locales
        export_request.platforms.each do |platform|
          locales.each do |locale|
            output_dir = find_or_create_locale_directory(
              export_request: export_request,
              locale: locale,
              platform: platform,
              default_locale: wording.default_locale
            )
            locale_wording = wording.translations_for(locale: locale)
            export_settings = platform.export_settings(locale_wording: locale_wording)
            export_settings.each do |file_type, parameters|
              path = output_dir.join(parameters[:filename])
              write_wording(file_type: file_type, hash_binding: parameters[:binding], path: path)
            end
          end
        end
      end

      private

      def find_or_create_locale_directory(export_request:, locale:, platform:, default_locale:)
        locale_output_path = platform_locale_output_path(
          platform: platform,
          locale: locale,
          default_locale: default_locale,
          export_request: export_request
        )
        locale_output_path.mkpath unless locale_output_path.directory?
        locale_output_path
      end

      def write_wording(file_type:, hash_binding:, path:)
        content = @builder.build(file_type: file_type, hash_binding: hash_binding)
        @output_strategy.write(path: path, content: content)
      end

      def platform_output_path(platform:, export_request:)
        export_request.multiple_platforms? ? export_request.output_path.join(platform.code.to_s) : export_request.output_path
      end

      def platform_locale_output_path(platform:, locale:, default_locale:, export_request:)
        path = platform_output_path(platform: platform, export_request: export_request)
        locale_directory_convention = Constant::CONFIG.dig(:platforms, :export_directory_names, platform.code)
        case platform.code
        when :ios
          path.join(locale_directory_convention % { locale: locale })
        when :android
          suffix = locale == default_locale ? "" : "-#{locale}"
          path.join(locale_directory_convention % { locale: suffix })
        else
          path
        end
      end
    end
  end
end