# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Interactors
    class MergeWordingsTest < TestCase
      MergeWordings::MERGE_POLICIES.each do |merge_policy|
        test "should keep plurals and adaptives only defined in merged wording with #{merge_policy} policy" do
          reference = wording_with(label: 'singular_label', type: Entities::WordingType::SINGULAR)
          plurals = wording_with(label: 'plural_label', type: Entities::WordingType::PLURAL, variant_name: 'one')
          adaptives = wording_with(label: 'adaptive_label', type: Entities::WordingType::ADAPTIVE, variant_name: '20')

          merged = MergeWordings.new.call(wordings: [reference, plurals, adaptives], merge_policy: merge_policy)

          assert_equal 'plural_label value', merged['en'].plurals['plural_label']['one'].value
          assert_equal 'adaptive_label value', merged['en'].adaptives['adaptive_label']['20'].value
        end
      end

      private

      def wording_with(label:, type:, variant_name: nil)
        locale_wording = Entities::LocaleWording.new(locale: 'en', is_default: true)
        key = Entities::Key.new(id: label, label: label, type: type, variant_name: variant_name)
        locale_wording.add_wording(key: key, value: "#{label} value", comment: nil)
        { 'en' => locale_wording }
      end
    end
  end
end
