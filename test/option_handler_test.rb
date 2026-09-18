# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  class OptionHandlerTest < TestCase
    test 'should parse -d option' do
      options = OptionHandler.parse!(%w[-d])
      assert options[:debug]
    end

    test 'should parse -e option' do
      options = OptionHandler.parse!(%w[-e])
      assert options[:'export-all-sheets']
    end

    test 'should parse -m option' do
      options = OptionHandler.parse!(%w[-m replace])
      assert_equal 'replace', options[:'merge-policy']

      options = OptionHandler.parse!(%w[-m keep])
      assert_equal 'keep', options[:'merge-policy']

      assert_raises(OptionParser::InvalidArgument) { OptionHandler.parse!(%w[-m other]) }
      assert_raises(OptionParser::MissingArgument) { OptionHandler.parse!(%w[-m]) }
    end

    test 'should parse excel file option' do
      options = OptionHandler.parse!(%w[-f https://example.com/wordings.xlsx])
      assert_equal 'https://example.com/wordings.xlsx', options[:'excel-file']

      options = OptionHandler.parse!(%w[--excel-file wordings.xlsx])
      assert_equal 'wordings.xlsx', options[:'excel-file']

      assert_raises(OptionParser::MissingArgument) { OptionHandler.parse!(%w[-f]) }
      assert_raises(OptionParser::InvalidOption) { OptionHandler.parse!(%w[-k spreadsheet_id -f wordings.xlsx]) }
    end

    test 'should parse -s option' do
      options = OptionHandler.parse!(%w[-s 1])
      assert_equal %w[1], options[:sheets]

      options = OptionHandler.parse!(%w[-s 1,2,3])
      assert_equal %w[1 2 3], options[:sheets]

      assert_raises(OptionParser::MissingArgument) { OptionHandler.parse!(%w[-s]) }
    end

    test 'should not keep values from previous parses' do
      OptionHandler.parse!(%w[-s Wordings])
      options = OptionHandler.parse!(%w[])

      assert_equal Requests::ExportRequest::DEFAULTS[:sheet_ids], options[:sheets]
    end

    test 'should parse -o option' do
      options = OptionHandler.parse!(%w[-o ios])
      assert_equal %w[ios], options[:only]

      options = OptionHandler.parse!(%w[-o ios,android])
      assert_equal %w[ios android], options[:only]

      options = OptionHandler.parse!(%w[-o other])
      assert_equal %w[other], options[:only]

      assert_raises(OptionParser::MissingArgument) { OptionHandler.parse!(%w[-o]) }
    end

    test 'should parse -t option' do
      assert_raises(OptionParser::MissingArgument) { OptionHandler.parse!(%w[-t]) }

      options = OptionHandler.parse!(%w[-t test_directory])
      assert_equal 'test_directory', options[:'target-dir']
    end

    test 'should parse -k option' do
      options = OptionHandler.parse!(%w[-k some_id])
      assert_equal 'some_id', options[:'drive-key']

      assert_raises(OptionParser::MissingArgument) { OptionHandler.parse!(%w[-k]) }
    end

    test 'should parse -x option' do
      options = OptionHandler.parse!(%w[-x])
      assert options[:'non-empty-values']
    end

    test 'should set non option arguments as csv_paths' do
      options = OptionHandler.parse!(%w[-k some_id -e -t foo bar foobar])
      assert_equal %w[bar foobar], options[:csv_paths]
    end

    test 'should parse -l option' do
      options = OptionHandler.parse!(%w[-l en])
      assert_equal %w[en], options[:locales]

      options = OptionHandler.parse!(%w[-l en,fr])
      assert_equal %w[en fr], options[:locales]

      assert_raises(OptionParser::MissingArgument) { OptionHandler.parse!(%w[-l]) }
    end
  end
end
