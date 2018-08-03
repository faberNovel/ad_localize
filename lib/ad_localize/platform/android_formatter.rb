module AdLocalize::Platform
  class AndroidFormatter < PlatformFormatter
    def platform
      :android
    end

    def export(locale, data, export_extension = nil, substitution_format = nil)
      locale = locale.to_sym
      export_dir_suffix = (locale == default_locale) ? "" : "-#{locale.downcase}"
      create_locale_dir(export_dir_suffix)

      xml_doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.resources {
          data.each do |key, wording|
            singular_wording = wording.dig(locale, AdLocalize::Constant::SINGULAR_KEY_SYMBOL)
            add_singular_wording_to_xml(key, singular_wording, xml) unless singular_wording.blank?

            plural_wording = wording.dig(locale, AdLocalize::Constant::PLURAL_KEY_SYMBOL)
            add_plural_wording_to_xml(key, plural_wording, xml) unless plural_wording.blank?
          end
        }
      end

      export_dir(export_dir_suffix).join(AdLocalize::Constant::ANDROID_EXPORT_FILENAME).open("w") do |file|
        file.puts xml_doc.to_xml(indent: 4)
      end
      AdLocalize::LOGGER.log(:debug, :black, "Android [#{locale}] ---> DONE!")
    end

    private
    def ios_converter(value)
      processedValue = value.gsub(/</, "&lt;")
      processedValue = processedValue.gsub(/>/, "&gt;")
      processedValue = processedValue.gsub(/(?<!\\)'/, "\\\\'")
      processedValue = processedValue.gsub(/(?<!\\)\"/, "\\\"")
      processedValue = processedValue.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
      processedValue = processedValue.gsub(/(%(\d+\$)?@)/, '%\2s') # should match values like %1$s and %s
      processedValue = processedValue.gsub(/(%((\d+\$)?(\d+)?)i)/, '%\2d') # should match values like %i, %3$i, %01i, %1$02i
      processedValue = processedValue.gsub(/%(?!((\d+\$)?(s|(\d+)?d)))/, '%%') # negative lookahead: identifies when user really wants to display a %
      processedValue = processedValue.gsub("\\U", "\\u")
      "\"#{processedValue}\""
    end

    def add_singular_wording_to_xml(key, text, xml)
      xml.string(name: key) {
        add_wording_text_to_xml(text, xml)
      }
    end

    def add_plural_wording_to_xml(key, plural_hash, xml)
      xml.plurals(name: key) {
        plural_hash.each do |plural_type, plural_text|
          next if plural_text.blank?
          xml.item(quantity: plural_type) {
            add_wording_text_to_xml(plural_text, xml)
          }
        end
      }
    end

    def add_wording_text_to_xml(wording_text, xml)
      raise 'Wording text should not be empty' if wording_text.blank?
      xml.text(
        ios_converter(wording_text)
      )
    end
  end
end