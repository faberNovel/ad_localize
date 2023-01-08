# require 'test_helper'

# module AdLocalize
#   module Mappers
#     class ValueRangeToWordingTest < TestCase

#       LOCALE = "en"

#       test 'should map correctly unique values' do
#         input = [
#           ["key1", "value1"],
#           ['key2##{one}', "value2one"],
#           ['key2##{other}', "value2other"],
#           ["key3", "value3"],
#         ]
#         output = [
#           ["key1", "value1"],
#           ['key2##{one}', "value2one"],
#           ['key2##{other}', "value2other"],
#           ["key3", "value3"],
#         ]
#         assert_valid_output(input, output)
#       end

#       test 'should skip duplicates' do
#         input = [
#           ["key1", "value1"],
#           ["key2", "value2"],
#           ["key2", "value2bis"],
#           ["key3", "value3"],
#         ]
#         output = [
#           ["key1", "value1"],
#           ["key2", "value2"],
#           ["key3", "value3"],
#         ]
#         assert_valid_output(input, output)
#       end

#       test 'should skip plural after singular' do
#         input = [
#           ["key1", "value1"],
#           ["key2", "value2"],
#           ['key2##{one}', "value2one"],
#           ["key3", "value3"],
#         ]
#         output = [
#           ["key1", "value1"],
#           ["key2", "value2"],
#           ["key3", "value3"],
#         ]
#         assert_valid_output(input, output)
#       end

#       test 'should skip singular after plural' do
#         input = [
#           ["key1", "value1"],
#           ['key2##{one}', "value2one"],
#           ["key2", "value2"],
#           ["key3", "value3"],
#         ]
#         output = [
#           ["key1", "value1"],
#           ['key2##{one}', "value2one"],
#           ["key3", "value3"],
#         ]
#         assert_valid_output(input, output)
#       end

#       private

#       def assert_valid_output(input, output)
#         value_range = Google::Apis::SheetsV4::ValueRange.new(values: [["key", LOCALE]] + input)
#         result = ValueRangeToWording.new.map(value_range: value_range)
#         expected = output.map { |key, value|
#           Entities::Translation.new(
#             locale: LOCALE,
#             key: Entities::Key.new(label: key),
#             value: value,
#           )
#         }
#         assert_equal result.locale_wordings.first.translations, expected
#       end

#     end
#   end
# end