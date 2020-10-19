require 'test_helper'

module AdLocalize
  module Entities
    class KeyTest < TestCase
      def setup
        @plural_key = Key.new(label: 'assess_rate_trip_voiceover##{one}')
        @adaptive_key = Key.new(label: 'start_countdown##{20}')
        @info_plist_key = Key.new(label: 'NSCameraUsageDescription')
        @singular_key = Key.new(label: 'delete')
      end

      test 'should compute plural key' do
        assert_equal 'one', @plural_key.plural_key
        assert_nil @adaptive_key.plural_key
        assert_nil @info_plist_key.plural_key
        assert_nil @singular_key.plural_key
      end

      test 'plural? should be true when there is a plural key' do
        assert @plural_key.plural?
        refute @adaptive_key.plural?
        refute @info_plist_key.plural?
        refute @singular_key.plural?
      end

      test 'should compute adaptive key' do
        assert_equal '20', @adaptive_key.adaptive_key
        assert_nil @plural_key.adaptive_key
        assert_nil @info_plist_key.adaptive_key
        assert_nil @singular_key.adaptive_key
      end

      test 'adaptive? should be true when there is an adaptive key' do
        assert @adaptive_key.adaptive?
        refute @plural_key.adaptive?
        refute @info_plist_key.adaptive?
        refute @singular_key.adaptive?
      end

      test 'info_plist? should be true when label respect info plist convention' do
        assert @info_plist_key.info_plist?
        refute @plural_key.info_plist?
        refute @adaptive_key.info_plist?
        refute @singular_key.info_plist?
      end

      test 'singular? should be true when key is not plural, adaptive nor info plist' do
        assert @singular_key.singular?
        refute @plural_key.singular?
        refute @info_plist_key.singular?
        refute @adaptive_key.singular?
      end

      test 'raw_label should be equal to the label without any treatment' do
        assert_equal 'assess_rate_trip_voiceover##{one}', @plural_key.raw_label
        assert_equal 'start_countdown##{20}', @adaptive_key.raw_label
        assert_equal 'NSCameraUsageDescription', @info_plist_key.raw_label
        assert_equal 'delete', @singular_key.raw_label
      end

      test 'same_as? should be true when keys have equal raw label' do
        same_adaptive_key = Key.new(label: 'start_countdown##{20}')
        assert @adaptive_key.same_as?(key: same_adaptive_key)
        other_adaptive_key = Key.new(label: 'start_countdown##{25}')
        refute @adaptive_key.same_as?(key: other_adaptive_key)

        same_plural_key = Key.new(label: 'assess_rate_trip_voiceover##{one}')
        assert @plural_key.same_as?(key: same_plural_key)
        other_plural_key = Key.new(label: 'assess_rate_trip_voiceover##{other}')
        refute @plural_key.same_as?(key: other_plural_key)

        same_singular_key = Key.new(label: 'delete')
        assert @singular_key.same_as?(key: same_singular_key)

        same_info_plist_key = Key.new(label: 'NSCameraUsageDescription')
        assert @info_plist_key.same_as?(key: same_info_plist_key)
      end
    end
  end
end
