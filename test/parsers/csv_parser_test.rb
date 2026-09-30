# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Parsers
    class CSVParserTest < TestCase
      test 'should trim whitespace on keys and translations' do
        # Given
        csv_path = "test/fixtures/reference_whitespace_stripping.csv"
        assert(File.exist?(csv_path), "File does not exists #{csv_path}")
        parser = Parsers::CSVParser.new
        export_request = Requests::ExportRequest.new

        # When
        wording = parser.call(csv_path: csv_path, export_request: export_request)

        # Then
        en_singular_wording = wording["en"].singulars

        assert_equal en_singular_wording["no_whitespaces"].key.label, "no_whitespaces"
        assert_equal en_singular_wording["before"].key.label, "before"
        assert_equal en_singular_wording["after"].key.label, "after"
        assert_equal en_singular_wording["both"].key.label, "both"

        assert_equal en_singular_wording["no_whitespaces"].value, "no_whitespaces"
        assert_equal en_singular_wording["before"].value, "before"
        assert_equal en_singular_wording["after"].value, "after"
        assert_equal en_singular_wording["both"].value, "both"
      end

      test 'should not trim whitespace on translation when strip is disabled' do
        # Given
        csv_path = "test/fixtures/reference_whitespace_stripping.csv"
        assert(File.exist?(csv_path), "File does not exists #{csv_path}")
        parser = Parsers::CSVParser.new
        export_request = Requests::ExportRequest.new
        export_request.skip_value_stripping = true

        # When
        wording = parser.call(csv_path: csv_path, export_request: export_request)

        # Then
        en_singular_wording = wording["en"].singulars

        assert_equal en_singular_wording["no_whitespaces"].key.label, "no_whitespaces"
        assert_equal en_singular_wording["before"].key.label, "before"
        assert_equal en_singular_wording["after"].key.label, "after"
        assert_equal en_singular_wording["both"].key.label, "both"

        assert_equal en_singular_wording["no_whitespaces"].value, "no_whitespaces"
        assert_equal en_singular_wording["before"].value, "  before"
        assert_equal en_singular_wording["after"].value, "after  "
        assert_equal en_singular_wording["both"].value, "  both  "
      end

      test 'should parse last row of a google sheet export without trailing newline' do
        # Given
        # Google Sheets exports use CRLF, quote fields containing a comma and have no trailing newline.
        # csv < 3.2.7 appended the key to the last value once the file exceeds one read chunk (32KB)
        rows = (1..1000).map do |i|
          fr_value = i == 1 ? "\"Valeur, #{i}\"" : "Valeur #{i}"
          "key_#{i},#{fr_value},Value #{i} after purchase."
        end
        csv_file = Tempfile.new(%w[no_trailing_newline .csv])
        csv_file.write("key,fr,en\r\n#{rows.join("\r\n")}")
        csv_file.close
        parser = Parsers::CSVParser.new
        export_request = Requests::ExportRequest.new

        # When
        wording = parser.call(csv_path: csv_file.path, export_request: export_request)

        # Then
        assert_equal "Valeur, 1", wording["fr"].singulars["key_1"].value
        assert_equal "Valeur 1000", wording["fr"].singulars["key_1000"].value
        assert_equal "Value 1000 after purchase.", wording["en"].singulars["key_1000"].value
      ensure
        csv_file&.unlink
      end
    end
  end
end
