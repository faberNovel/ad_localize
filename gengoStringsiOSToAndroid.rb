#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'

TEMP_FILE = "temp_replace.xml"
FORMATTED_REGEXP = /%(\d+\$)?s/

Dir.glob(File.join("res", "**", "strings.xml")) {|file_name|
    puts "---------------------"
    puts "Processing file #{file_name}"
    text = File.read(file_name)
    replace = text.gsub(/\&(?!amp;)/, "&amp;")
    replace = replace.gsub(/(%(\d+\$)?@)/, '%\2s')
    File.open(TEMP_FILE, "w") {|file|
        file.puts replace
    }
    pluralHash = Hash.new
    File.open(file_name, "w") {|file|
        File.open(TEMP_FILE).each do |line|
            if line.scan(/(?:\")(\w+)##\{(zero|one|two|few|many|other)\}(?:\">)(.*)(?:<\/string>)/).count() > 0
                a = line.match(/(?:\")(\w+)##\{(zero|one|two|few|many|other)\}(?:\">)(.*)(?:<\/string>)/)
                if pluralHash[a[1]] == nil
                    pluralHash[a[1]] = {a[2] => a[3]}
                else
                    pluralHash[a[1]][a[2]] = a[3]
                end
            elsif line.scan(FORMATTED_REGEXP).count() > 1
                data = line.match(/(<string name=\"\w+\")(?:>)/)
                line = line.gsub(data[1].to_s, data[1].to_s + " formatted=\"false\"") if data != nil
                file.puts line
            elsif line === "</resources>\n"
                pluralHash.keys.each do |key|
                    file.puts "    <plurals name=\"#{key}\">"
                    pluralHash[key].keys.each do |string_key|
                        formatted = pluralHash[key][string_key].scan(FORMATTED_REGEXP).count() > 1 ? " formatted=\"false\"" : ""
                        file.puts "        <item quantity=\"#{string_key}\"#{formatted}>#{pluralHash[key][string_key]}</item>"
                    end
                    file.puts "    </plurals>"
                end
                file.puts line
            else
                file.puts line
            end
        end
    }
    File.delete(TEMP_FILE)
    puts "Done"
}
