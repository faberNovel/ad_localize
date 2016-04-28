#!/usr/bin/env ruby
#encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'csv'
require 'optparse'
require 'yaml'
require 'pathname'
require 'fileutils'
require 'logger'
require 'open-uri'
require 'json'
require 'byebug'
require 'nokogiri'
require 'active_support'
require 'colorize'

############################################################
## @Requirement : csv wording keys must be in snake case  ##
############################################################
# TODO:
# - define a Wording class that has methods such as has_singular, has_plural, singulars, plurals
# - define methods to get data formatted for a techno
#

def csv_wording_key_column
  "key"
end

def plural_regexp
  /\#\#\{(\w+)\}/
end

def black_log(level, log)
  @logger.add(level, log.black)
end

def yellow_log(level, log)
  @logger.add(level, log.yellow)
end

def red_log(level, log)
  @logger.add(level, log.red)
end

def drive_download_url(key)
  "https://docs.google.com/spreadsheets/d/#{key}/export?format=csv&id=#{key}"
end

def download_from_drive(key)
  downloaded_file_name = "./#{key}.csv"
  File.open(downloaded_file_name, "wb") do |saved_file|
    # the following "open" is provided by open-uri
    open(drive_download_url(key), "rb") do |read_file|
      saved_file.write(read_file.read)
    end
  end
  downloaded_file_name
end

def find_locales(row)
  wording_key_index = row.index(csv_wording_key_column)
  @locales = row.headers.slice((wording_key_index+1)..-1)
  black_log Logger::DEBUG, "DETECTED LOCALES : #{@locales}"
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
    red_log(Logger::ERROR, "Missing key in line #{$.}") unless row.fields.all?(&:nil?)
    valid_row = 0
  elsif not row.headers.include?(csv_wording_key_column)
    red_log Logger::ERROR, "[CSV FORMAT] #{file_name} is not a valid file"
    valid_row = -1
  end
  return valid_row
end

def parse_key(row)
  key = row.field(csv_wording_key_column)
  plural_prefix = key.match(plural_regexp)

  if plural_prefix.nil?
    plural_identifier = nil
    numeral_key = :singular
  else
    key.slice!(plural_prefix[0])
    plural_identifier = plural_prefix[1]
    numeral_key = :plural
  end
  { key: key.to_sym, numeral_key: numeral_key, plural_identifier: plural_identifier&.to_sym }
end

def wording_default(locale, key)
  @logger.level == Logger::DEBUG ? "<[#{locale.upcase}] Missing translation for #{key}>" : ""
end

def check_arguments(value, locale, key)
  formatted_arguments = value&.scan(/%(\d$)?@/) || []
  if formatted_arguments.size >= 2
    is_all_ordered = formatted_arguments.inject(true){|is_ordered, match| is_ordered &&= (not match.first.nil?) }
    red_log Logger::WARN, "[#{locale.upcase}] Multiple format specifier for #{key} with no order" unless is_all_ordered
  end
end

def parse_row(row)
  key_infos = parse_key(row)
  @locales.each_with_object({ key_infos.dig(:key) => {} }) do |locale, memo|
    memo[key_infos.dig(:key)][locale.to_sym] = { key_infos.dig(:numeral_key) => {} } unless memo[key_infos.dig(:key)].key? locale.to_sym
    if key_infos.dig(:plural_identifier).nil?
      if row[locale]
        black_log Logger::DEBUG, "[#{locale.upcase}] Singular key ---> #{key_infos.dig(:key)}"
      else
        yellow_log Logger::WARN, "[#{locale.upcase}] Missing translation for #{key_infos.dig(:key)}"
      end
      value = row[locale] || wording_default(locale, key_infos.dig(:key))
    else
      if row[locale]
        black_log Logger::DEBUG, "[#{locale.upcase}] Plural key ---> plural_identifier : #{key_infos.dig(:plural_identifier)}, key : #{key_infos.dig(:key)}"
      else
        yellow_log Logger::WARN, "[#{locale.upcase}] Missing translation for #{key_infos.dig(:key)} (#{key_infos.dig(:plural_identifier)})"
      end
      value = { key_infos.dig(:plural_identifier) => row[locale] || wording_default(locale, "#{key_infos.dig(:key)} (#{key_infos.dig(:plural_identifier)})") }
    end
    check_arguments(row[locale], locale, key_infos.dig(:key))
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
    else
      find_locales(row) if @locales.nil?
      data.deep_merge!(parse_row(row))
    end
  end
  data
end

def write_to_ios_singular(export_dir,locale, data)
  locale_sym = locale.to_sym
  singulars = data.select {|key, wording| wording.dig(locale_sym)&.key? :singular}
  if singulars.empty?
    black_log Logger::INFO, "Not enough content to generate Localizable.strings for #{locale.upcase} - no singular keys were found"
    return true
  end

  singulars.each do |key, wording|
    translations = wording[locale_sym]
    value = translations&.dig(:singular)
    export_dir.join("Localizable.strings").open("a") do |file|
      file.puts "\"#{key}\" = \"#{value}\";\n"
    end
  end
  black_log Logger::DEBUG, "iOS singular ---> DONE!"
end

def write_to_ios_plural(export_dir,locale, data)
  locale_sym = locale.to_sym
  plurals = data.select {|key, wording| wording[locale_sym]&.key? :plural}
  if plurals.empty?
    black_log Logger::INFO, "Cannot generate Localizable.stringsdict for #{locale.upcase} - no plural keys were found"
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
  black_log Logger::DEBUG, "iOS plural ---> DONE!"
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
  black_log Logger::DEBUG, "Android ---> DONE!"
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

def angular_substitution_format(value)
  value.gsub(/(%(\d+\$)?@)/, '{\2s}')
end

def write_to_json(export_dir, locale, data)
  write_to(export_dir, locale, data, "json", "angular") do |json_data, file|
    file.puts json_data.to_json
  end
  black_log Logger::DEBUG, "JSON ---> DONE!"
end

def yml_substitution_format(value)
  value.gsub(/(%(?!)?(\d+\$)?[@isd])/, "VARIABLE_TO_SET")
end

def write_to_yml(export_dir, locale, data)
  write_to(export_dir, locale, data, "yml", "yml") do |yml_data, file|
    file.puts yml_data.to_yaml
  end
  black_log Logger::DEBUG, "YML ---> DONE!"
end

def export(data)
  black_log Logger::DEBUG, "GENERATING WORDING FILES..."
  @locales.each do |locale|
    has_wording = data.select{ |key, wording| wording.key? locale.to_sym }.count > 0
    next unless has_wording
    black_log Logger::DEBUG, "******* #{locale.upcase} *******"
    export_dir = locale_dir(locale)
    write_to_android(export_dir, locale, data)
    write_to_ios_singular(export_dir, locale, data)
    write_to_ios_plural(export_dir,locale, data)
    write_to_yml(export_dir, locale, data)
    write_to_json(export_dir, locale, data)
  end
end

def parse_options
  options = { debug: false }
  OptionParser.new do |opt|
    opt.banner = "Usage: ruby exportCSVStrings.rb [options] file(s)"
    opt.on("-d", "--debug", "running in debug mode") do
      options[:debug] = true
    end
    opt.on("-h", "--help", "Prints help") do
      puts "Usage: ruby exportCSVStrings.rb [options] file name(s)\n-d, --debug : running for debug mode\n-k, --drive-key : Download spreadsheet from google drive"
      exit
    end
    opt.on("-k", "--drive-key", "Download spreadsheet from google drive") do
      options[:drive_key] = true
    end
  end.parse!
  options
end

def initialize_vars(options)
  @logger = Logger.new(STDOUT)
  @logger.level = options[:debug]? Logger::DEBUG : Logger::INFO
  @locales = nil
end

def is_csv(file)
  valid_content_types = %w(text/csv text/plain)
  valid_content_types.include? `file --brief --mime-type #{file}`.strip
end

def file_to_parse(options, arg)
  file_name = arg
  if options[:drive_key]
    black_log Logger::INFO, "Downloading file from google drive..."
    file_name = download_from_drive(arg)
    unless is_csv(file_name)
      red_log Logger::ERROR, "The downloaded file is not a csv. Check that the spreadsheet is readable with shareable link"
      exit
    end
  end
  file_name
end

# MAIN
if ARGV.size.zero?
  puts "[COMPLETE] That was quick, you didn't provide any file to parse"
else
  options = parse_options
  initialize_vars(options)
  black_log Logger::INFO, "OPTIONS : #{options}"
  ARGV.each do |arg|
    black_log Logger::INFO, "********* PARSING #{arg} *********"
    black_log Logger::INFO, "Extracting data from file..."
    data = extract_data(file_to_parse(options, arg))
    if data.empty?
      red_log Logger::ERROR, "No data were found in the file - cannot start the file generation process"
    else
      export(data)
    end
  end
end