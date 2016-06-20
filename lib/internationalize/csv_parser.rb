require 'csv'
require 'active_support'

module Internationalize
  class CsvParser
    CSV_WORDING_KEYS_COLUMN = "key"
    PLURAL_KEY_REGEXP = /\#\#\{(\w+)\}/

    attr_accessor :locales

    def initialize
      @locales = []
    end

    # Raise a StandardError if no locale is detected in the csv
    def extract_data(file_name)
      data = {}
      CSV.foreach(file_name, headers: true, skip_blanks: true) do |row|
        validity_status = check_row(row)
        if validity_status.zero?
          next
        elsif validity_status == -1
          exit
        else
          find_locales(row) if locales.empty?
          row_data = parse_row(row)
          data.deep_merge!(row_data) unless row_data.nil?
        end
      end
      data
    end

    private
    # Returns 1 if row is ok, 0 if row there are missing information and -1 if row is not a csv row
    def check_row(row)
      valid_row = 1
      # Check non empty row
      if row.field(CSV_WORDING_KEYS_COLUMN).nil?
        LOGGER.log(:error, :red, "Missing key in line #{$.}") unless row.fields.all?(&:nil?)
        valid_row = 0
      elsif not row.headers.include?(CSV_WORDING_KEYS_COLUMN)
        LOGGER.log(:error, :red, "[CSV FORMAT] #{file_name} is not a valid file")
        valid_row = -1
      end
      return valid_row
    end

    def find_locales(row)
      ignore_before_index = row.index(CSV_WORDING_KEYS_COLUMN)
      self.locales = row.headers.slice((ignore_before_index+1)..-1).compact if row.length > ignore_before_index
      if locales.empty?
        raise 'NO DETECTED LOCALES'
      else
        LOGGER.log(:debug, :black, "DETECTED LOCALES : #{locales.join(', ')}")
      end
    end

    def parse_row(row)
      key_infos = parse_key(row)
      return nil if key_infos.nil?

      locales.each_with_object({ key_infos.dig(:key) => {} }) do |locale, output|
        current_key = key_infos.dig(:key)
        current_key_already_has_wording_for_locale = output[current_key].key? locale.to_sym
        output[current_key][locale.to_sym] = { key_infos.dig(:numeral_key) => {} } unless current_key_already_has_wording_for_locale

        if key_infos.dig(:numeral_key) == Constant::SINGULAR_KEY_SYMBOL
          trace_wording(row[locale], "[#{locale.upcase}] Singular key ---> #{current_key}", "[#{locale.upcase}] Missing translation for #{current_key}")
          value = row[locale] || default_wording(locale, current_key)
        elsif key_infos.dig(:numeral_key) == Constant::PLURAL_KEY_SYMBOL
          trace_wording(row[locale],
            "[#{locale.upcase}] Plural key ---> plural_identifier : #{key_infos.dig(:plural_identifier)}, key : #{current_key}",
            "[#{locale.upcase}] Missing translation for #{current_key} (#{key_infos.dig(:plural_identifier)})")
          value = { key_infos.dig(:plural_identifier) => row[locale] || default_wording(locale, "#{current_key} (#{key_infos.dig(:plural_identifier)})") }
        else
          raise "Unknown numeral key #{key_infos.dig(:numeral_key)}"
        end

        check_wording_parameters(row[locale], locale, current_key)
        output[current_key][locale.to_sym][key_infos.dig(:numeral_key)] = value
      end
    end

    def parse_key(row)
      key = row.field(CSV_WORDING_KEYS_COLUMN)
      plural_prefix = key.match(PLURAL_KEY_REGEXP)
      plural_identifier = nil
      invalid_plural = false

      if plural_prefix.nil?
        numeral_key = Constant::SINGULAR_KEY_SYMBOL
      else
        numeral_key = Constant::PLURAL_KEY_SYMBOL
        key = plural_prefix.post_match
        plural_identifier = plural_prefix.captures&.first
        LOGGER.log(:debug, :red, "Invalid key #{key}") if key.nil?
        LOGGER.log(:debug, :red, "Empty plural prefix!") if plural_identifier.nil?
        invalid_plural = plural_identifier.nil?
      end

      (key.nil? or invalid_plural) ? nil : { key: key.to_sym, numeral_key: numeral_key, plural_identifier: plural_identifier&.to_sym }
    end

    def default_wording(locale, key)
      LOGGER.debug? ? "<[#{locale.upcase}] Missing translation for #{key}>" : ""
    end

    def trace_wording(wording, present_message, missing_message)
      if wording
        LOGGER.log(:debug, :black, present_message)
      else
        LOGGER.log(:debug, :yellow, missing_message)
      end
    end

    def check_wording_parameters(value, locale, key)
      formatted_arguments = value&.scan(/%(\d$)?@/) || []
      if formatted_arguments.size >= 2
        is_all_ordered = formatted_arguments.inject(true){ |is_ordered, match| is_ordered &&= !match.join.empty? }
        LOGGER.log(:warn, :red, "[#{locale.upcase}] Multiple arguments for #{key} but no order") unless is_all_ordered
      end
    end
  end
end