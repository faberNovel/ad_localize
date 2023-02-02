# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Entities
    class SimpleWordingTest < TestCase
      test 'should create simple wording with all attributes' do
        key = Key.new(id: 'id', label: 'label', variant_name: 'variant_name', type: 'type')
        value = 'value'
        comment = 'comment'
        simple_wording = SimpleWording.new(key: key, value: value, comment: comment)
        assert_equal key, simple_wording.key
        assert_equal value, simple_wording.value
        assert_equal comment, simple_wording.comment
      end
    end
  end
end
