# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Sanitizers
    class ARBSanitizerTest < TestCase
      test 'should return nil when value is blank' do
        assert_nil ARBSanitizer.new.sanitize(value: nil)
        assert_nil ARBSanitizer.new.sanitize(value: "")
        assert_nil ARBSanitizer.new.sanitize(value: " ")
      end

      test 'should not modify values without special characters' do
        assert_equal "test", ARBSanitizer.new.sanitize(value: "test")
      end

      test 'should convert numbered format specifiers to placeholders' do
        sanitizer = ARBSanitizer.new
        value = "du %1$@ au %2$@, %3$d jours à %4$.2f €"
        assert_equal "du {p1} au {p2}, {p3} jours à {p4} €", sanitizer.sanitize(value: value)
        assert_equal(
          { "p1" => "String", "p2" => "String", "p3" => "int", "p4" => "double" },
          sanitizer.placeholders(value: value)
        )
      end

      test 'should convert unnumbered format specifiers in order' do
        sanitizer = ARBSanitizer.new
        value = "%@ has %i messages"
        assert_equal "{p1} has {p2} messages", sanitizer.sanitize(value: value)
        assert_equal({ "p1" => "String", "p2" => "int" }, sanitizer.placeholders(value: value))
      end

      test 'should sort placeholders by index' do
        assert_equal(
          { "p1" => "int", "p2" => "String" },
          ARBSanitizer.new.placeholders(value: "%2$@ %1$d")
        )
      end

      test 'should return no placeholders without format specifiers' do
        assert_equal({}, ARBSanitizer.new.placeholders(value: "100% sure"))
      end

      test 'should handle percent signs' do
        assert_equal "100% sure, 50%", ARBSanitizer.new.sanitize(value: "100% sure, 50%%")
      end

      test 'should escape ICU special characters' do
        result = ARBSanitizer.new.sanitize(value: "l'appli { } {{%1$@}}")
        assert_equal "l''appli '{' '}' '{{'{p1}'}}'", result
      end

      test 'should unescape quotes and line breaks' do
        assert_equal "String \"escaped\"\nnew line", ARBSanitizer.new.sanitize(value: "String \\\"escaped\\\"\\nnew line")
      end
    end
  end
end
