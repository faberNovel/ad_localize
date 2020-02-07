module AdLocalize::Platform
  class PlatformFormatter
    PLURAL_KEY_SYMBOL = :plural
    SINGULAR_KEY_SYMBOL = :singular
    OPTIONS = {output_path: ".."}

    attr_accessor :platform_dir
    attr_reader :default_locale, :output_path

    def initialize(default_locale, output_path)
      @default_locale = default_locale.to_sym
      @output_path = output_path # Must be set before platform_dir
      @platform_dir = export_base_directory.join(platform.to_s)
      create_platform_dir
    end

    def platform
      raise 'Please override me!'
    end

    def export(locale, data, export_extension, substitution_format)
      locale = locale.to_sym
      formatted_data = data.each_with_object({}) do |(key, wording), hash_acc|
        hash_acc[locale.to_s] = {} unless hash_acc.key? locale.to_s
        if wording.dig(locale)&.key? :singular
          value = ios_converter(wording.dig(locale, :singular))
          hash_acc[locale.to_s][key.to_s] = value
        end
        if wording.dig(locale)&.key? :plural
          hash_acc[locale.to_s][key.to_s] = {}
          wording.dig(locale, :plural).each do |plural_type, plural_text|
            value = ios_converter(plural_text)
            hash_acc[locale.to_s][key.to_s][plural_type.to_s] = value
          end
        end
      end

      platform_dir.join("#{locale.to_s}.#{export_extension}").open("w") do |file|
        yield(formatted_data, file)
      end

      AdLocalize::LOGGER.log(:debug, :green, "#{platform.to_s.upcase} [#{locale}] ---> DONE!")
    end

    protected
    def export_base_directory
      if output_path
        Pathname.new(output_path)
      else
        Pathname::pwd.join(AdLocalize::Constant::EXPORT_FOLDER)
      end
    end

    def create_platform_dir
      if platform_dir.directory?
        FileUtils.rm_rf("#{platform_dir}/.", secure: true)
      else
        platform_dir.mkpath
      end
    end

    def export_dir(locale)
      platform_dir + AdLocalize::Constant::CONFIG.dig(:platforms, :export_directory_names, platform.to_sym) % { locale: locale.downcase }
    end

    def create_locale_dir(locale)
      raise 'Locale needed' unless locale

      if export_dir(locale).directory?
        FileUtils.rm_rf("#{export_dir(locale)}/.", secure: true)
      else
        export_dir(locale).mkdir
      end
    end
  end
end
