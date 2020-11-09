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
      end

      test 'should map translation value for android' do
        android_view_model = AndroidTranslationMapper.new.map(translation: @translation)
        assert_equal @translation.key.label, android_view_model.label
        assert_nil android_view_model.key
        assert_equal(
          "\"Caractères spéciaux autorisés : - / : ; ( ) € \\&#38; @ . , ? ! \\&#39; [ ] { } # \\&#37; ^ * + = _ | ~ \\&lt; \\&gt; $ £ ¥ ` ° \\&#34;\"",
          android_view_model.value
          )
        assert_equal @translation.comment, android_view_model.comment
      end
    end
  end
end