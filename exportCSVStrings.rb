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

# /!\ wording keys must be in snake case

def csv_key_column_name
  "key"
end

def plural_regexp
  /\#\#\{(\w+)\}(\w+)/
end

def organized_csv_data(file_name, debug_mode)
  locales = nil
  data = {}
  CSV.foreach(file_name, headers: true, skip_blanks: true) do |row|
    if locales.nil?
      locales = row.headers.reject { |header| %w(key ecran).include? header.downcase }
      @logger.debug "CSV LOCALES : #{locales}" if debug_mode
    end

    # Check if the key is plural
    key = row.field(csv_key_column_name)
    non_empty_fields = row.fields.reject {|f| f.nil? }
    if key.nil? or (non_empty_fields.count == 0)
      @logger.error("Missing key in line #{$.}") if key.nil? and (non_empty_fields.count > 0)
      next
    end

    plural_prefix = key[plural_regexp,1]
    if plural_prefix.nil?
      @logger.debug "Singular key ---> #{key}" if debug_mode

      data[key.to_sym] = {} unless data.key? key.to_sym
      locales.map do |locale|
        next unless row[locale]
        data[key.to_sym][locale.to_sym] = { singular: row[locale] }
      end
    else
      key = row[csv_key_column_name][plural_regexp,2]
      @logger.debug "Plural key ---> plural_identifier : #{plural_prefix}, key : #{key}" if debug_mode

      data[key.to_sym] = {} unless data.key? key.to_sym
      locales.map do |locale|
        next unless row[locale]
        data[key.to_sym][locale.to_sym] = { plural: {} } unless data[key.to_sym].key? locale.to_sym
        data[key.to_sym][locale.to_sym][:plural][plural_prefix.to_sym] = row[locale]
      end
    end
  end
  data
end

def export(organized_data, debug_mode)
  if organized_data.empty?
    @logger.info "Not enough content to generate wording files"
    return true
  end
  keys = organized_data.keys
  locales = organized_data[keys.first].keys
  locales.each do |locale|
    has_wording = organized_data.select{ |key, wording| wording.key? locale }.count > 0
    next unless has_wording
    @logger.debug "generates empty directory for locale : #{locale.upcase}" if debug_mode
    export_dir = locale_dir(locale)
    @logger.debug "generates android wording file" if debug_mode
    write_to_android(export_dir, locale, organized_data)
    @logger.debug "generates ios singular wording file" if debug_mode
    write_to_ios_singular(export_dir, locale, organized_data)
    @logger.debug "generates ios plural wording file" if debug_mode
    write_to_ios_plural(export_dir,locale, organized_data)
    @logger.debug "generates yml wording file" if debug_mode
    write_to_yml(export_dir, locale, organized_data)
    @logger.debug "generates json wording file" if debug_mode
    write_to_json(export_dir, locale, organized_data)
  end
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

def write_to_ios_singular(export_dir,locale, data)
  singulars = data.select {|key, wording| wording[locale]&.key? :singular}
  if singulars.empty?
    @logger.info "Not enough content to generate Localizable.strings"
    return true
  end

  singulars.each do |key, wording|
    translations = wording[locale]
    value = translations&.dig(:singular)
    export_dir.join("Localizable.strings").open("a") do |file|
      file.puts "\"#{key}\" = \"#{value}\";\n"
    end
  end
end

def write_to_ios_plural(export_dir,locale, data)
  plurals = data.select {|key, wording| wording[locale]&.key? :plural}
  if plurals.empty?
    @logger.info "Not enough content to generate Localizable.stringsdict"
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
  export_dir.join("Localizable.stringsdict").open("w") do |file|
    file.puts xml_doc.to_xml
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
  xml_doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.resources{
      data.each do |key, wording|
        if wording.dig(locale)&.key? :singular
          xml.string(name: key) {
            xml.text(convertStringToAndroid(wording.dig(locale, :singular)))
          }
        end
        if wording.dig(locale)&.key? :plural
          xml.plurals(name: key) {
            wording.dig(locale, :plural).each do |plural_type, plural_text|
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
    file.puts xml_doc.to_xml
  end
end

def write_to_json(export_dir, locale, data)
  write_to(export_dir, locale, data, "json", "angular") do |json_data, file|
    file.puts json_data.to_json
  end
end

def write_to_yml(export_dir, locale, data)
  write_to(export_dir, locale, data, "yml", "yml") do |yml_data, file|
    file.puts yml_data.to_yaml
  end
end

def angular_substitution_format(value)
  value.gsub(/(%(\d+\$)?@)/, '{\2s}')
end

def yml_substitution_format(value)
  value.gsub(/(%(?!)?(\d+\$)?[@isd])/, "VARIABLE_TO_SET")
end

def write_to(export_dir, locale, data, export_extension, substitution_format)
  formatted_data = data.each_with_object({}) do |(key, wording), hash_acc|
    hash_acc[locale.to_s] = {} unless hash_acc.key? locale.to_s
    if wording.dig(locale)&.key? :singular
      value = send("#{substitution_format}_substitution_format", wording.dig(locale, :singular))
      hash_acc[locale.to_s][key.to_s] = value
    end
    if wording.dig(locale)&.key? :plural
      hash_acc[locale.to_s][key.to_s] = {} unless hash_acc[locale.to_s].key? key.to_s
      wording.dig(locale, :plural).each do |plural_type, plural_text|
        value = send("#{substitution_format}_substitution_format", plural_text)
        hash_acc[locale.to_s][key.to_s][plural_type.to_s] = value
      end
    end
  end
  export_dir.join("#{locale}.#{export_extension}").open("w") do |file|
    yield(formatted_data, file)
  end
end

# MAIN
# Parse options
options = { debug: false }
OptionParser.new do |opt|
  opt.banner = "Usage: ruby exportCSVStrings.rb [options] file"
  opt.on("-d", "--debug", "running for debug mode") do
    options[:debug] = true
  end
end.parse!

# Start the process
@logger = Logger.new(STDOUT)
@logger.level = Logger::DEBUG

if ARGV.size.zero?
  puts "Usage: ruby exportCSVStrings.rb [options] file_to_parse"
else
  @logger.info "FILE(S) TO PARSE : #{ARGV}"
  @logger.info "OPTIONS : #{options}"

  ARGV.each do |file_name|
    data = organized_csv_data(file_name, options[:debug])
    export(data, options[:debug])
  end
end

