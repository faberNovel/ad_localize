#!/usr/bin/env ruby
#encoding: utf-8

require 'rubygems'
require 'csv'
require 'builder'
require 'pp'
require './convertValues'

ARGV.each do |a|
    puts a
end

ANDROID_XML_MARKUP_HASH = Hash.new
IOS_FILE_HASH = Hash.new

#def initAndroidFile(lang)
#    file = File.open("strings-#{lang}.xml", "w")
#    file.puts "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
#    file.puts "<resources>"
#    return file
#end

CSV.read("data.csv", :headers => true).headers().each do |header|
    if header != "key"
        ANDROID_XML_MARKUP_HASH[header] = Builder::XmlMarkup.new(:indent=>4)
        IOS_FILE_HASH[header] = File.open("Localizable-#{header}.strings", "w")
    end
end

def writeToIOS(file, key, value)
    file.puts "\"#{key}\" = \"#{value}\";"
end

def writeToAndroid(xml, key, value)
    xml.string(value, "name" => key)
end

CSV.foreach("data.csv", :headers => true) do |row|
   IOS_FILE_HASH.keys.each do |lang|
       writeToIOS(IOS_FILE_HASH[lang], row["key"], row[lang])
   end
   ANDROID_XML_MARKUP_HASH.keys.each do |lang|
       writeToAndroid(ANDROID_XML_MARKUP_HASH[lang], row["key"], row[lang])
   end
end

def closeAndroidFiles
    ANDROID_XML_MARKUP_HASH.keys.each do |lang|
        xml = ANDROID_XML_MARKUP_HASH[lang]
        file = File.open("strings-#{lang}.xml", "w");
        file_xml = Builder::XmlMarkup.new(:target => file, :indent=>4)
        file_xml.instruct!
        file_xml.resources {
            file_xml << xml.target!
        }
        file.close
        convertValues(file.path)
    end
end

closeAndroidFiles

