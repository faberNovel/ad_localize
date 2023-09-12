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

      test 'should not escape "%" if escaping is not enabled' do
        percentage_value = "% abcdef 100% %1$@% 10 %. abcdef %"
        sanitized_value = IOSSanitizer.new.sanitize(value: percentage_value)
        assert_equal "% abcdef 100% %1$@% 10 %. abcdef %", sanitized_value
      end

      test 'should escape "%" when needed' do
        percentage_value = "% abcdef 100% %1$@% %10$@ %$@ 10 %. abcdef %"
        sanitizer = IOSSanitizer.new
        sanitizer.should_auto_escape_percent = true
        sanitized_value = sanitizer.sanitize(value: percentage_value)
        assert_equal "%% abcdef 100%% %1$@%% %10$@ %%$@ 10 %%. abcdef %%", sanitized_value
      end

      test 'should not escape "%" when not needed for ios' do
        percentage_value = "%@ %1$@ %s %i %d %X %ld"
        sanitizer = IOSSanitizer.new
        sanitizer.should_auto_escape_percent = true
        sanitized_value = sanitizer.sanitize(value: percentage_value)
        assert_equal "%@ %1$@ %s %i %d %X %ld", sanitized_value
      end

      test 'should escape "%" even when repeated for ios' do
        percentage_value = "% %% %%% %%%%"
        sanitizer = IOSSanitizer.new
        sanitizer.should_auto_escape_percent = true
        sanitized_value = sanitizer.sanitize(value: percentage_value)
        assert_equal "%% %%%% %%%%%% %%%%%%%%", sanitized_value
      end
    end
  end
end
