require 'test_helper'

module AdLocalize
    module Entities
        class LocaleWordingTest < TestCase
            setup do
                @key = Key.new(id: 'id', label: 'label', variant_name: 'variant_name', type: 'type')
                @locale = 'en'
                @is_default = true
                @value = 'value'
                @comment = 'comment'
            end

            test 'should create locale wording' do
                locale_wording = LocaleWording.new(locale: @locale, is_default: @is_default)
                assert_equal @locale, locale_wording.locale
                assert_equal @is_default, locale_wording.is_default
                assert_empty locale_wording.singulars
                assert_empty locale_wording.plurals
                assert_empty locale_wording.info_plists
                assert_empty locale_wording.adaptives
            end

            test 'should add plural wording' do
                @key.type = WordingType::PLURAL
                locale_wording = LocaleWording.new(locale: @locale, is_default: @is_default)
                assert_difference -> { locale_wording.plurals.size } do
                    locale_wording.add_wording(key: @key, value: @value, comment: @comment)
                    plural = locale_wording.plurals[@key.label].last
                    assert_equal @value, plural.value
                    assert_equal @comment, plural.comment
                end
            end

            test 'should add adaptive wording' do
                @key.type = WordingType::ADAPTIVE
                locale_wording = LocaleWording.new(locale: @locale, is_default: @is_default)
                assert_difference -> { locale_wording.adaptives.size } do
                    locale_wording.add_wording(key: @key, value: @value, comment: @comment)
                    adaptive = locale_wording.adaptives[@key.label].last
                    assert_equal @value, adaptive.value
                    assert_equal @comment, adaptive.comment
                end
            end

            test 'should add info plist wording' do
                @key.type = WordingType::INFO_PLIST
                locale_wording = LocaleWording.new(locale: @locale, is_default: @is_default)
                assert_difference -> { locale_wording.info_plists.size } do
                    locale_wording.add_wording(key: @key, value: @value, comment: @comment)
                    info_plist = locale_wording.info_plists.last
                    assert_equal @value, info_plist.value
                    assert_equal @comment, info_plist.comment
                end
            end

            test 'should add singular wording' do
                @key.type = WordingType::SINGULAR
                locale_wording = LocaleWording.new(locale: @locale, is_default: @is_default)
                assert_difference -> { locale_wording.singulars.size } do
                    locale_wording.add_wording(key: @key, value: @value, comment: @comment)
                    singular = locale_wording.singulars.last
                    assert_equal @value, singular.value
                    assert_equal @comment, singular.comment
                end
            end
        end
    end
end
