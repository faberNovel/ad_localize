require 'test_helper'

module AdLocalize
    module Entities
        class KeyTest < TestCase
            test 'should create key with all attributes' do
                id = 'id'
                label = 'label'
                variant_name = 'variant_name'
                type = 'type'
                key = Key.new(id: id, label: label, variant_name: variant_name, type: type)
                assert_equal id, key.id
                assert_equal label, key.label
                assert_equal variant_name, key.variant_name
                assert_equal type, key.type
            end
        end
    end
end