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


def get_locales(csv)
  csv.headers.each_with_object([]) do |header, result|
    result << header unless %w(key ecran).include? header.downcase
  end
end

def create_locale_files(locales, prefix)
  locale_file_names = ["Localizable.strings", "strings.xml"]
  locales.each do |locale|
    locale_directory_path = Pathname::pwd.join(locale.upcase)
    locale_directory_path.rmtree if locale_directory_path.directory?
    locale_directory_path.mkdir
    locale_file_names.concat [ "#{locale}.json", "#{locale}.yml"]
    locale_file_names.each do |file_name|
      File.new(locale_directory_path.join("#{prefix}#{file_name}"), "w")
    end
  end
end

def writeToIOS(file, key, value)
  file.puts "\"#{key}\" = \"#{value}\";"
end

def writeToJSON(hash, key, value)
  hash[key] = convertStringToAngularTemplate value
end

# TODO: return file data in a hash
def get_data_from_csv(csv, languages)
  csv.each_with_index do |row, i|
    usable_row = true
    %w(key).concat(languages).each do |header|
      usable_row = false if row.field(header).nil?
    end
    if usable_row
      # languages.each do |lang|
      #   byebug
      #   writeToIOS(ios_file_hash[lang], row["key"], debugValue(row[lang], mode))
      #   writeToAndroid(android_xml_hash[lang], row["key"], debugValue(row[lang], mode))
      #   writeToJSON(json_hash[lang], row["key"], debugValue(row[lang], mode))
      # end
    else
      puts "There are missing values in line #{i}"
    end
  end
end

# MAIN
options = { debug: false, prefix: "" }
OptionParser.new do |opt|
  opt.banner = "Usage: ruby exportCSVStrings.rb [options] file"
  opt.on("-d", "--debug", "running for debug mode") do
    options[:debug] = true
  end
  opt.on("-p", "--prefix", "prefix generated files") do |prefix|
    options[:prefix] = prefix
  end
end.parse!



if ARGV.size.zero?
  puts "Usage: ruby exportCSVStrings.rb [options] file_to_parse"
else
  puts "FILE(S) TO PARSE : #{ARGV}"
  puts "OPTIONS : #{options}"
  ARGV.each do |file_name|
    csv = CSV.read(file_name, :headers => true, :skip_blanks => true)
    prefix = options[:prefix]
    locales = get_locales(csv)
    create_locale_files(locales, prefix)
    get_data_from_csv(csv, locales)
    # TODO: generate_files
    # exportCSV(file_name, prefix, options[:debug])
  end
end


# # ANDROID
# xml_doc = REXML::Document.new(nil, {attribute_quote: :quote, raw: :all})
# xml_doc << REXML::XMLDecl.new('1.0', 'utf-8')
# xml_doc.add_element "resources"
# platform_hashes[:android_xml_hash][header] = xml_doc

# # iOS
# platform_hashes[:ios_file_hash][header] = locale_directory_path.join("#{prefix}Localizable.strings")
# platform_hashes[:json_hash][header] = Hash.new
# def convertStringToAndroid(value)
#     processedValue = value.gsub(/</, "&lt;")
#     processedValue = processedValue.gsub(/>/, "&gt;")
#     processedValue = processedValue.gsub(/(?<!\\)'/, "\\\\'")
#     processedValue = processedValue.gsub(/(?<!\\)\"/, "\\\"")
#     processedValue = processedValue.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
#     processedValue = processedValue.gsub(/(%(\d+\$)?@)/, '%\2s')
#     processedValue = processedValue.gsub(/(%(\d+\$)?i)/, '%\2d')
#     processedValue = processedValue.gsub(/%(?!(\d+\$)?[sd])/, '\%%')
#     processedValue = processedValue.gsub("\\U", "\\u")
#     value = "\"#{processedValue}\""
# end

# def convertStringToAngularTemplate(value)
#     value.gsub(/(%(\d+\$)?@)/, '{\2s}')
# end

# PLURALIZE_IDENTIFIERS = [:zero, :one, :two, :few, :many, :other]
# def writeToAndroid(xml, key, value, )
#     value = convertStringToAndroid(value)
#     PLURALIZE_IDENTIFIERS.each {|w|
#         if (key =~ /\#\#\{#{w}\}/)
#             shortkey = key.gsub("##\{#{w}\}", "")
#             existingElem = xml.root.elements.to_a("//plurals[@name='#{shortkey}']")
#             if (existingElem.size > 0)
#                 elem = existingElem.first
#                 elem = elem.add_element "item", {"quantity" => w}
#                 elem.text = value
#             else
#                 elem = xml.root.add_element "plurals", {"name" => shortkey}
#                 elem = elem.add_element "item", {"quantity" => w}
#                 elem.text = value
#             end
#             return
#         end
#     }
#     elem = xml.root.add_element "string", {"name" => key}
#     elem.text = value
# end

# def exportCSV(argument, prefix, mode)
#     # CSV.foreach(argument, :headers => true, :skip_blanks => true) do |row|
#     #     if (!row.empty?)
#     #         ios_file_hash.keys.each do |lang|
#     #             writeToIOS(ios_file_hash[lang], row["key"], debugValue(row[lang], mode))
#     #         end
#     #         android_xml_hash.keys.each do |lang|
#     #             writeToAndroid(android_xml_hash[lang], row["key"], debugValue(row[lang], mode))
#     #         end
#     #         json_hash.each_key do |lang|
#     #             writeToJSON(json_hash[lang], row["key"], debugValue(row[lang], mode))
#     #         end
#     #     end
#     # end

#     # android_xml_hash.keys.each do |lang|
#     #     file = File.open("#{prefix}strings-#{lang}.xml", "w");
#     #     formatter = REXML::Formatters::Pretty.new(4)
#     #     formatter.compact = true
#     #     formatter.width = Float::INFINITY
#     #     formatter.write(android_xml_hash[lang], file)
#     #     file.close
#     # end

#     # # Turns {'a:b:c' => 42} into {'a' => {'b' => {'c' => 42}}}
#     # def expand_by_splitting_keys(hash, separator = ':')
#     #     expanded_hash = {}
#     #     hash.each do |key, value|
#     #       *subkeys, last = key.split(':')
#     #       subhash = expanded_hash
#     #       subkeys.each do |subkey|
#     #         subhash[subkey] ||= {}
#     #         subhash = subhash[subkey]
#     #       end
#     #       subhash[last] = value
#     #     end
#     #     return expanded_hash
#     # end

#     # json_hash.each do |lang, values|
#     #     file = File.open("#{prefix}locale-#{lang}.json", "w")
#     #     file.write(values.to_json)
#     #     file.close

#     #     file = File.open("#{prefix}locale-#{lang}.yml", "w")
#     #     file.write({lang => expand_by_splitting_keys(values)}.to_yaml)
#     #     file.close
#     # end
# end

