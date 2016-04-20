#!/usr/bin/env ruby
#encoding: utf-8

require 'csv'
require 'rexml/document'
require 'optparse'
require 'json'
require 'yaml'
require 'byebug'
require 'pathname'
require 'fileutils'
require 'logger'
require 'nokogiri'
require 'active_support'

############################################################
## @Requirement : csv wording keys must be in snake case  ##
############################################################

def csv_wording_key_column
  "key"
end

def plural_regexp
  /\#\#\{(\w+)\}/
end

def find_locales(row)
  wording_key_index = row.index(csv_wording_key_column)
  @locales = row.headers.slice((wording_key_index+1)..-1)
  @logger.debug "DETECTED LOCALES : #{@locales}"
end

def locale_dir(locale)
  locale_directory_path = Pathname::pwd.join(locale.to_s.upcase)
  if locale_directory_path.directory?
    FileUtils.rm_rf("#{locale_directory_path}/.", secure: true)
  else
    locale_directory_path.mkdir
  end
  locale_directory_path
end

# Returns 1 if row is ok, 0 if row there are missing information and -1 if row is not a csv row
def check_row(row)
  valid_row = 1
  # Check non empty row
  if row.field(csv_wording_key_column).nil?
    @logger.error("Missing key in line #{$.}") unless row.fields.all?(&:nil?)
    valid_row = 0
  elsif not row.headers.include?(csv_wording_key_column)
    @logger.error "[CSV FORMAT] #{file_name} is not a valid file"
    valid_row = -1
  end
  return valid_row
end

def parse_key(row)
  key = row.field(csv_wording_key_column)
  plural_prefix = key.match(plural_regexp)
  plural_identifier = nil
  numeral_key = :singular
  unless plural_prefix.nil?
    key.slice!(plural_prefix[0])
    plural_identifier = plural_prefix[1]
    numeral_key = :plural
  end
  { key: key.to_sym, numeral_key: numeral_key, plural_identifier: plural_identifier&.to_sym }
end

def parse_row(row)
  key_infos = parse_key(row)
  @locales.each_with_object({ key_infos.dig(:key) => {} }) do |locale, memo|
    next unless row[locale]
    memo[key_infos.dig(:key)][locale.to_sym] = { key_infos.dig(:numeral_key) => {} } unless memo[key_infos.dig(:key)].key? locale.to_sym
    if key_infos.dig(:plural_identifier).nil?
      @logger.debug "Singular key ---> #{key_infos.dig(:key)}"
      value = row[locale]
    else
      @logger.debug "Plural key ---> plural_identifier : #{key_infos.dig(:plural_identifier)}, key : #{key_infos.dig(:key)}"
      value = { key_infos.dig(:plural_identifier) => row[locale] }
    end
      memo[key_infos.dig(:key)][locale.to_sym][key_infos.dig(:numeral_key)] = value
  end
end

def extract_data(file_name)
  data = {}
  CSV.foreach(file_name, headers: true, skip_blanks: true) do |row|
    validity_status = check_row(row)
    if validity_status.zero?
      next
    elsif validity_status == -1
      exit
    end
    find_locales(row) if @locales.nil?
    data.deep_merge!(parse_row(row))
  end
  data
end

def export(data)
  @logger.debug "GENERATING WORDING FILES..."
  @locales.each do |locale|
    has_wording = data.select{ |key, wording| wording.key? locale.to_sym }.count > 0
    next unless has_wording
    @logger.debug "******* #{locale.upcase} *******"
    export_dir = locale_dir(locale)
    write_to_android(export_dir, locale, data)
    @logger.debug "Android ---> DONE!"
    write_to_ios_singular(export_dir, locale, data)
    @logger.debug "iOS singular ---> DONE!"
    write_to_ios_plural(export_dir,locale, data)
    @logger.debug "iOS plural ---> DONE!"
    write_to_yml(export_dir, locale, data)
    @logger.debug "YML ---> DONE!"
    write_to_json(export_dir, locale, data)
    @logger.debug "JSON ---> DONE!"
  end
end

def write_to_ios_singular(export_dir,locale, data)
  locale_sym = locale.to_sym
  singulars = data.select {|key, wording| wording.dig(locale_sym)&.key? :singular}
  if singulars.empty?
    @logger.info "Not enough content to generate Localizable.strings for #{locale.upcase} - no singular keys were found"
    return true
  end

  singulars.each do |key, wording|
    translations = wording[locale_sym]
    value = translations&.dig(:singular)
    export_dir.join("Localizable.strings").open("a") do |file|
      file.puts "\"#{key}\" = \"#{value}\";\n"
    end
  end
end

def write_to_ios_plural(export_dir,locale, data)
  locale_sym = locale.to_sym
  plurals = data.select {|key, wording| wording[locale_sym]&.key? :plural}
  if plurals.empty?
    @logger.info "Cannot generate Localizable.stringsdict for #{locale.upcase} - no plural keys were found"
    return true
  end

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
              translations[locale_sym].each do |wording_type, wording_value|
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
  export_dir.join("Localizable.stringsdict").open("w") do |file|
    file.puts xml_doc.to_xml(indent: 4)
  end
end

def convertStringToAndroid(value)
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

def write_to_android(export_dir, locale, data)
  locale_sym = locale.to_sym
  xml_doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.resources{
      data.each do |key, wording|
        if wording.dig(locale_sym)&.key? :singular
          xml.string(name: key) {
            xml.text(convertStringToAndroid(wording.dig(locale_sym, :singular)))
          }
        end
        if wording.dig(locale_sym)&.key? :plural
          xml.plurals(name: key) {
            wording.dig(locale_sym, :plural).each do |plural_type, plural_text|
              xml.item(quantity: plural_type) {
                xml.text(convertStringToAndroid(plural_text))
              }
            end
          }
        end
      end
    }
  end
  export_dir.join("strings.xml").open("w") do |file|
    file.puts xml_doc.to_xml(indent: 4)
  end
end

def angular_substitution_format(value)
  value.gsub(/(%(\d+\$)?@)/, '{\2s}')
end

def write_to_json(export_dir, locale, data)
  write_to(export_dir, locale, data, "json", "angular") do |json_data, file|
    file.puts json_data.to_json
  end
end

def yml_substitution_format(value)
  value.gsub(/(%(?!)?(\d+\$)?[@isd])/, "VARIABLE_TO_SET")
end

def write_to_yml(export_dir, locale, data)
  write_to(export_dir, locale, data, "yml", "yml") do |yml_data, file|
    file.puts yml_data.to_yaml
  end
end

def write_to(export_dir, locale, data, export_extension, substitution_format)
  locale_sym = locale.to_sym
  formatted_data = data.each_with_object({}) do |(key, wording), hash_acc|
    hash_acc[locale.to_s] = {} unless hash_acc.key? locale.to_s
    if wording.dig(locale_sym)&.key? :singular
      value = send("#{substitution_format}_substitution_format", wording.dig(locale_sym, :singular))
      hash_acc[locale.to_s][key.to_s] = value
    end
    if wording.dig(locale_sym)&.key? :plural
      hash_acc[locale.to_s][key.to_s] = {} unless hash_acc[locale.to_s].key? key.to_s
      wording.dig(locale_sym, :plural).each do |plural_type, plural_text|
        value = send("#{substitution_format}_substitution_format", plural_text)
        hash_acc[locale.to_s][key.to_s][plural_type.to_s] = value
      end
    end
  end
  export_dir.join("#{locale.to_s}.#{export_extension}").open("w") do |file|
    yield(formatted_data, file)
  end
end

# MAIN
# Parse options
options = { debug: false }
OptionParser.new do |opt|
  opt.banner = "Usage: ruby exportCSVStrings.rb [options] file(s)"
  opt.on("-d", "--debug", "running for debug mode") do
    options[:debug] = true
  end
  opt.on("-h", "--help", "Prints help") do
    puts "Usage: ruby exportCSVStrings.rb [options] file name(s)"
    exit
  end
end.parse!

# Process
if ARGV.size.zero?
  puts "[COMPLETE] That was quick, you didn't provide any file to parse"
else
  @logger = Logger.new(STDOUT)
  @logger.level = options[:debug]? Logger::DEBUG : Logger::INFO
  @locales = nil
  @logger.info "OPTIONS : #{options}"
  ARGV.each do |file_path|
    @logger.info "********* PARSING #{file_path} *********"
    @logger.info "Extracting data from file ..."
    data = extract_data(file_path)
    if data.empty?
      @logger.info "No data were found in the file - cannot start the file generation process"
    else
      export(data)
    end
  end
end