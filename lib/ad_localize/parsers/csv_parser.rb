module AdLocalize
  module Parsers
    class CSVParser
      COMMENT_KEY_COLUMN_IDENTIFIER = 'comment'.freeze
      CSV_WORDING_KEYS_COLUMN = 'key'.freeze
      
      def initialize(key_parser: nil)
        @key_parser = key_parser.presence || KeyParser.new
      end

      def call(csv_path:, options:)
        locales = find_locales(csv_path:, options:)
        keys = find_keys(csv_path:)
        wording = build_wording(csv_path:, locales:, keys:, options:)
        wording
      end
      
      private
      
      def find_locales(csv_path:, options:)
        csv = CSV.open(csv_path, headers: true, skip_blanks: true)
        headers = csv.first.headers
        locales = headers[headers.index(CSV_WORDING_KEYS_COLUMN).succ..-1].compact.reject do |header|
          header.include?(COMMENT_KEY_COLUMN_IDENTIFIER)
        end
        options[:locales].empty? ? locales : locales & options[:locales]
      end

      def find_keys(csv_path:)
        keys = {}
        CSV.foreach(csv_path, headers: true, skip_blanks: true, skip_lines: /^#/) do |row|
          raw_key = row[CSV_WORDING_KEYS_COLUMN].strip
          key = @key_parser.call(raw_key:)

          existing_key = keys.values.detect do |k|
            k.id == key.id || (k.label == key.label && (k.variant_name.nil? || key.variant_name.nil?))
          end
          if existing_key
            LOGGER.warn "A #{existing_key.type} value already exist for key '#{existing_key.label}'. Will skip new #{key.type} value. Remove duplicates."
          else
            keys[raw_key] = key
          end
        end
        keys
      end

      def build_wording(csv_path:, locales:, keys:, options:)
        default_locale = locales.first
        wording = Hash.new { |hash, key| hash[key] = Entities::LocaleWording.new(locale: key, is_default: key == default_locale) }
        added_keys = Hash.new { |hash, key| hash[key] = false }
        CSV.foreach(csv_path, headers: true, skip_blanks: true, skip_lines: /^#/) do |row|
          raw_key = row[CSV_WORDING_KEYS_COLUMN].strip
          key = keys[raw_key]
          next if key.nil? || added_keys[raw_key]

          locales.each do |locale|
            value = row[locale]
            next if options[:bypass_empty_values] && value.nil?

            comment = row["#{COMMENT_KEY_COLUMN_IDENTIFIER} #{locale}"]
            wording[locale].add_wording(key:, value:, comment:)
          end
          added_keys[raw_key] = true
        end
        wording
      end
    end
  end
end
