# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Sanitizers
    class IOSToAndroidSanitizerTest < TestCase
      test 'should not map nil value' do
        assert_nil IOSToAndroidSanitizer.new.sanitize(value: nil)
      end

      test 'should not map empty value' do
        assert_nil IOSToAndroidSanitizer.new.sanitize(value: nil)
      end

      test 'should map list of autorized characters for android' do
        password_specialchar_error = "Caractères spéciaux autorisés : - / : ; ( ) € & @ . , ? ! ' [ ] { } # % ^ * + = _ | ~ < > $ £ ¥ ` ° \""
        sanitized_value = IOSToAndroidSanitizer.new.sanitize(value: password_specialchar_error)
        expected_value = "\"Caractères spéciaux autorisés : - / : ; ( ) € \\&#38; @ . , ? ! \\&#39; [ ] { } # % ^ * + = _ | ~ \\&lt; \\&gt; $ £ ¥ ` ° \\&#34;\""
        assert_equal expected_value, sanitized_value
      end

      test 'should not escape "%" when not needed for android' do
        percentage_value = "100%"
        sanitized_value = IOSToAndroidSanitizer.new.sanitize(value: percentage_value)
        assert_equal "\"100%\"", sanitized_value
      end

      test 'should escape "%" when needed for android' do
        formatted_string_value = "%1$@ %"
        sanitized_value = IOSToAndroidSanitizer.new.sanitize(value: formatted_string_value)
        assert_equal "\"%1$s %%\"", sanitized_value
      end
    end
  end
end
