# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Sanitizers
    class IOSSanitizerTest < TestCase
      test 'should return nil when value is blank' do
        assert_nil IOSSanitizer.new.sanitize(value: nil)
        assert_nil IOSSanitizer.new.sanitize(value: "")
        assert_nil IOSSanitizer.new.sanitize(value: " ")
      end

      test 'should not modify values without escaping char' do
        value = "test"
        result = IOSSanitizer.new.sanitize(value: value)
        assert_equal value, result
      end

      test 'should handle escaping values' do
        skip('fix me')
        result = IOSSanitizer.new.sanitize(value: "String \\\"escaped\\\"")
        assert_equal "String \"escaped\"", result
      end

      test 'should handle unescaped values with double quote' do
        skip('fix me')
        result = IOSSanitizer.new.sanitize(value: "String \"unescaped\"")
        assert_equal "String \"unescaped\"", result
      end
    end
  end
end
