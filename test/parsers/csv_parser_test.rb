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
    end
  end
end
