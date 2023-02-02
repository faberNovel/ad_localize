# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Entities
    class KeyTest < TestCase
      test 'should create key with id' do
        id = 'id'
        key = Key.new(id: id)
        assert_equal id, key.id
      end

      test 'should create key with label' do
        label = 'label'
        key = Key.new(label: label)
        assert_equal label, key.label
      end

      test 'should create key with variant name' do
        variant_name = 'variant_name'
        key = Key.new(variant_name: variant_name)
        assert_equal variant_name, key.variant_name
      end

      test 'should create key with type' do
        type = 'type'
        key = Key.new(type: type)
        assert_equal type, key.type
      end
    end
  end
end
