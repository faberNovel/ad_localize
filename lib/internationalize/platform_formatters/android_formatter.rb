require_relative 'platform_formatter'

module Internationalize::Platform
  class AndroidFormatter < PlatformFormatter
    def platform
      :android
    end

    def export(locale, data, export_extension=nil, substitution_format=nil)
      locale = locale.to_sym
      export_dir_suffix = (locale == default_locale) ? "" : "-#{locale}"
      create_locale_dir(export_dir_suffix)

      xml_doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.resources{
          data.each do |key, wording|
            if wording.dig(locale)&.key? Internationalize::Constant::SINGULAR_KEY_SYMBOL
              xml.string(name: key) {
                xml.text(ios_converter(wording.dig(locale, Internationalize::Constant::SINGULAR_KEY_SYMBOL)))
              }
            end
            if wording.dig(locale)&.key? Internationalize::Constant::PLURAL_KEY_SYMBOL
              xml.plurals(name: key) {
                wording.dig(locale, Internationalize::Constant::PLURAL_KEY_SYMBOL).each do |plural_type, plural_text|
                  xml.item(quantity: plural_type) {
                    xml.text(ios_converter(plural_text))
                  }
                end
              }
            end
          end
        }
      end

      export_dir(export_dir_suffix).join("strings.xml").open("w") do |file|
        file.puts xml_doc.to_xml(indent: 4)
      end
      Internationalize::LOGGER.log(:debug, :black, "Android ---> DONE!")
    end

    private
    def ios_converter(value)
      processedValue = value.gsub(/</, "&lt;")
      processedValue = processedValue.gsub(/>/, "&gt;")
      processedValue = processedValue.gsub(/(?<!\\)'/, "\\\\'")
      processedValue = processedValue.gsub(/(?<!\\)\"/, "\\\"")
      processedValue = processedValue.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
      processedValue = processedValue.gsub(/(%(\d+\$)?@)/, '%\2s')
      processedValue = processedValue.gsub(/(%(\d+\$)?i)/, '%\2d')
      processedValue = processedValue.gsub(/%(?!(\d+\$)?[sd])/, '\%%')
      processedValue = processedValue.gsub("\\U", "\\u")
      value = "\"#{processedValue}\""
    end
  end
end