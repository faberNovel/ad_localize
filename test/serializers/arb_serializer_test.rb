# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Serializers
    class ARBSerializerTest < TestCase
      def setup
        @key_parser = Parsers::KeyParser.new
      end

      test 'should render singular wordings with description' do
        wordings = [
          ['delete', 'Supprimer', 'Delete button'],
          ['login.email.title', 'Email', nil]
        ]
        locale_wording = build_locale_wording(locale: 'fr', wordings: wordings)

        assert_equal(
          {
            '@@locale' => 'fr',
            'delete' => 'Supprimer',
            '@delete' => { 'description' => 'Delete button' },
            'login_email_title' => 'Email'
          },
          render(locale_wording: locale_wording)
        )
      end

      test 'should skip empty values' do
        locale_wording = build_locale_wording(locale: 'fr', wordings: [['empty', '', nil], ['send', 'Envoyer', nil]])

        assert_equal({ '@@locale' => 'fr', 'send' => 'Envoyer' }, render(locale_wording: locale_wording))
      end

      test 'should render placeholders metadata' do
        locale_wording = build_locale_wording(locale: 'en', wordings: [['from_to', 'from %1$@ to %2$@', nil]])

        content = render(locale_wording: locale_wording)
        assert_equal 'from {p1} to {p2}', content['from_to']
        assert_equal(
          { 'placeholders' => { 'p1' => { 'type' => 'String' }, 'p2' => { 'type' => 'String' } } },
          content['@from_to']
        )
      end

      test 'should render plurals as ICU messages' do
        wordings = [
          ['rate##{one}', 'Rate %1$@ star', nil],
          ['rate##{other}', 'Rate %1$@ stars', 'Rating']
        ]
        locale_wording = build_locale_wording(locale: 'en', wordings: wordings)

        content = render(locale_wording: locale_wording)
        assert_equal '{count, plural, one{Rate {p1} star} other{Rate {p1} stars}}', content['rate']
        assert_equal(
          {
            'description' => 'Rating',
            'placeholders' => { 'count' => { 'type' => 'int' }, 'p1' => { 'type' => 'String' } }
          },
          content['@rate']
        )
      end

      test 'should convert locale to flutter convention' do
        locale_wording = build_locale_wording(locale: 'pt-BR', wordings: [['send', 'Enviar', nil]])

        assert_equal 'pt_BR', render(locale_wording: locale_wording)['@@locale']
      end

      private

      def build_locale_wording(locale:, wordings:)
        locale_wording = Entities::LocaleWording.new(locale: locale, is_default: true)
        wordings.each do |raw_key, value, comment|
          locale_wording.add_wording(key: @key_parser.call(raw_key: raw_key), value: value, comment: comment)
        end
        locale_wording
      end

      def render(locale_wording:)
        JSON.parse(ARBSerializer.new.render(locale_wording: locale_wording))
      end
    end
  end
end
