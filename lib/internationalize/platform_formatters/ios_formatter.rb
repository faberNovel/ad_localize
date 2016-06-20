require_relative 'platform_formatter'

module Internationalize::Platform
  class IosFormatter < PlatformFormatter
    def platform
      :ios
    end

    def export(locale, data, export_extension=nil, substitution_format=nil)
      create_locale_dir(locale)
      [Internationalize::Constant::PLURAL_KEY_SYMBOL, Internationalize::Constant::SINGULAR_KEY_SYMBOL].each do |numeral_key|
        numeral_data = data.select {|key, wording| wording.dig(locale.to_sym)&.key? numeral_key}
        if numeral_data.empty?
          Internationalize::LOGGER.log(:info, :black, "Not enough content to generate Localizable.strings for #{locale.upcase} - no singular keys were found")
        else
          send("write_#{numeral_key}", locale, numeral_data)
        end
      end
    end

    protected
    def write_singular(locale, singulars)
      locale = locale.to_sym

      singulars.each do |key, locales_wording|
        value = locales_wording.dig(locale, Internationalize::Constant::SINGULAR_KEY_SYMBOL)
        export_dir(locale).join(Internationalize::Constant::IOS_SINGULAR_EXPORT_FILENAME).open("a") do |file|
          file.puts "\"#{key}\" = \"#{value}\";\n"
        end
      end
      Internationalize::LOGGER.log(:debug, :black, "iOS singular ---> DONE!")
    end

    def write_plural(locale, plurals)
      locale = locale.to_sym

      xml_doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.plist {
          xml.dict {
            plurals.each do |wording_key, translations|
              xml.key wording_key
              xml.dict {
                xml.key "NSStringLocalizedFormatKey"
                xml.string "%\#@key@"
                xml.key "key"
                xml.dict {
                  xml.key "NSStringFormatSpecTypeKey"
                  xml.string "NSStringPluralRuleType"
                  xml.key "NSStringFormatValueTypeKey"
                  xml.string "d"
                  translations[locale].each do |wording_type, wording_value|
                    wording_value.each do |plural_identifier, plural_value|
                      xml.key plural_identifier
                      xml.string plural_value
                    end
                  end
                }
              }
            end
          }
        }
      end
      export_dir(locale).join(Internationalize::Constant::IOS_PLURAL_EXPORT_FILENAME).open("w") do |file|
        file.puts xml_doc.to_xml(indent: 4)
      end
      Internationalize::LOGGER.log(:debug, :black, "iOS plural ---> DONE!")
    end
  end
end