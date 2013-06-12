#!/usr/bin/env ruby
# encoding: utf-8

TEMP_FILE = "temp_replace.xml"


Dir.glob(File.join("res", "**", "strings.xml")) {|file_name|
    puts "---------------------"
    puts "Processing file #{file_name}"
    text = File.read(file_name)
    replace = text.gsub(/\&(?!amp;)/, "&amp;")
    replace = replace.gsub(/(%(\d+\$)?@)/, '%\2s')
    File.open(TEMP_FILE, "w") {|file|
        file.puts replace
    }
    File.open(file_name, "w") {|file|
        File.open(TEMP_FILE).each do |line|
            if line.scan(/%(\d+\$)?@/).count() > 1
                a = line.match(/<string name=\"\w+\">/)
                line = line.gsub(a.to_s, a.to_s.chomp('>') + " formatted=\"false\">") if a != nil
            end
            file.puts line
        end
    }
    File.delete(TEMP_FILE)
    puts "Done"
}
