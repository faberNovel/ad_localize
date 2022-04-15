require 'test_helper'

module AdLocalize
  module Mappers
    class AndroidTranslationMapperTest < TestCase
      setup do
        @translation = Entities::Translation.new(
          locale: 'fr',
          key: Entities::Key.new(label: 'password_specialchar_error'),
          value: "Caractères spéciaux autorisés : - / : ; ( ) € & @ . , ? ! ' [ ] { } # % ^ * + = _ | ~ < > $ £ ¥ ` ° \"",
          comment: "liste des caractères autorisés"
          )
        @translation_percent_without_formatting = Entities::Translation.new(
          locale: 'fr',
          key: Entities::Key.new(label: 'non_escaped_percent'),
          value: "100%"
          )
        @translation_percent_with_formatting = Entities::Translation.new(
          locale: 'fr',
          key: Entities::Key.new(label: 'non_escaped_percent'),
          value: "%1$@ %"
          )
      end

      test 'should map translation value for android' do
        android_view_model = AndroidTranslationMapper.new.map(translation: @translation)
        assert_equal @translation.key.label, android_view_model.label
        assert_nil android_view_model.key
        assert_equal(
          "\"Caractères spéciaux autorisés : - / : ; ( ) € \\&#38; @ . , ? ! \\&#39; [ ] { } # % ^ * + = _ | ~ \\&lt; \\&gt; $ £ ¥ ` ° \\&#34;\"",
          android_view_model.value
          )
        assert_equal @translation.comment, android_view_model.comment
      end

      test 'should not escape "%" when not needed for android' do
        android_view_model = AndroidTranslationMapper.new.map(translation: @translation_percent_without_formatting)
        assert_equal @translation_percent_without_formatting.key.label, android_view_model.label
        assert_nil android_view_model.key
        assert_equal(
          "\"100%\"",
          android_view_model.value
          )
      end

      test 'should escape "%" when needed for android' do
        android_view_model = AndroidTranslationMapper.new.map(translation: @translation_percent_with_formatting)
        assert_equal @translation_percent_with_formatting.key.label, android_view_model.label
        assert_nil android_view_model.key
        assert_equal(
          "\"%1$s %%\"",
          android_view_model.value
          )
      end
    end
  end
end