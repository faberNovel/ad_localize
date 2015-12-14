#!/usr/bin/env ruby
#encoding: utf-8

require 'csv'
require 'rexml/document'
require 'optparse'
require 'json'
require 'yaml'

options = {}
options[:debug] = false

puts ARGV
opt_parser = OptionParser.new do |opt|
    opt.on("-d", "--debug", "running for debug mode") do
        options[:debug] = true
    end
end.parse!

puts options
puts ARGV

PLURALIZE_IDENTIFIERS = [:zero, :one, :two, :few, :many, :other]

def exportCSV(argument, prefix, mode)

    prefix = "" if prefix == nil

    android_xml_hash = Hash.new
    ios_file_hash = Hash.new
    json_hash = Hash.new
    CSV.read(argument, :headers => true, :skip_blanks => true).headers().each do |header|
        if header != "key"
            xml_doc = REXML::Document.new
            xml_doc.context[:attribute_quote] = :quote
            xml_doc.context[:raw] = :all
            xml_doc << REXML::XMLDecl.new('1.0', 'utf-8')
            xml_doc.add_element "resources"
            android_xml_hash[header] = xml_doc
            ios_file_hash[header] = File.open("#{prefix}Localizable-#{header}.strings", "w")
            json_hash[header] = Hash.new
        end
    end

    def writeToIOS(file, key, value)
        file.puts "\"#{key}\" = \"#{value}\";"
    end

    def writeToJSON(hash, key, value)
        hash[key] = convertStringToAngularTemplate value
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

    def convertStringToAngularTemplate(value)
        value.gsub(/(%(\d+\$)?@)/, '{\2s}')
    end

    def writeToAndroid(xml, key, value)
        value = convertStringToAndroid(value)
        PLURALIZE_IDENTIFIERS.each {|w|
            if (key =~ /\#\#\{#{w}\}/)
                shortkey = key.gsub("##\{#{w}\}", "")
                existingElem = xml.root.elements.to_a("//plurals[@name='#{shortkey}']")
                if (existingElem.size > 0)
                    elem = existingElem.first
                    elem = elem.add_element "item", {"quantity" => w}
                    elem.text = value
                else
                    elem = xml.root.add_element "plurals", {"name" => shortkey}
                    elem = elem.add_element "item", {"quantity" => w}
                    elem.text = value
                end
                return
            end
        }
        elem = xml.root.add_element "string", {"name" => key}
        elem.text = value
    end

    def debugValue(value, mode)
        if value == nil
            if mode
                value = "<Missing Translation>"
            else
                value = ""
            end
        end
        return value
    end

    CSV.foreach(argument, :headers => true, :skip_blanks => true) do |row|
        if (!row.empty?)
            ios_file_hash.keys.each do |lang|
                writeToIOS(ios_file_hash[lang], row["key"], debugValue(row[lang], mode))
            end
            android_xml_hash.keys.each do |lang|
                writeToAndroid(android_xml_hash[lang], row["key"], debugValue(row[lang], mode))
            end
            json_hash.each_key do |lang|
                writeToJSON(json_hash[lang], row["key"], debugValue(row[lang], mode))
            end
        end
    end

    android_xml_hash.keys.each do |lang|
        file = File.open("#{prefix}strings-#{lang}.xml", "w");
        formatter = REXML::Formatters::Pretty.new(4)
        formatter.compact = true
        formatter.width = Float::INFINITY
        formatter.write(android_xml_hash[lang], file)
        file.close
    end

    # Turns {'a:b:c' => 42} into {'a' => {'b' => {'c' => 42}}}
    def expand_by_splitting_keys(hash, separator = ':')
        expanded_hash = {}
        hash.each do |key, value|
          *subkeys, last = key.split(':')
          subhash = expanded_hash
          subkeys.each do |subkey|
            subhash[subkey] ||= {}
            subhash = subhash[subkey]
          end
          subhash[last] = value
        end
        return expanded_hash
    end

    json_hash.each do |lang, values|
        file = File.open("#{prefix}locale-#{lang}.json", "w")
        file.write(values.to_json)
        file.close

        file = File.open("#{prefix}locale-#{lang}.yml", "w")
        file.write({lang => expand_by_splitting_keys(values)}.to_yaml)
        file.close
    end
end

ARGV.each do |file_name|
    exportCSV(file_name, nil, options[:debug])
end
