module AdLocalize
  module Mappers
    class CSVPathToWording
      def map(csv_path:)
        @headers = CSV.foreach(csv_path).first
        return unless valid?(csv_path: csv_path)
        translations = []

        CSV.foreach(csv_path, headers: true, skip_blanks: true) do |row|
          row_translations = map_row(row: row, locales: locales)
          next if row_translations.blank?

          existing_keys = translations.map(&:key)
          new_translations = row_translations.reject do |translation|
            existing_keys.any? do |key|
              existing_plural_key = key.label == translation.key.label && key.plural? && translation.key.singular?
              key.same_as?(key: translation.key) || existing_plural_key
            end
          end
          translations.concat(new_translations)
        end

        locale_wordings = translations.group_by(&:locale).map do |locale, group|
          Entities::LocaleWording.new(locale: locale, translations: group)
        end
        Entities::Wording.new(locale_wordings: locale_wordings, default_locale: locales.first)
      end

      private

      def valid?(csv_path:)
        File.exist?(csv_path) && has_key_column? && has_locales?
      end

      def locales
        @locales ||= compute_locales
      end

      def compute_locales
        return [] unless has_key_column? && key_column_index < @headers.size.pred

        @headers.slice(key_column_index.succ..-1).compact.reject do |header|
          header.to_s.include?(Constant::COMMENT_KEY_COLUMN_IDENTIFIER)
        end
      end

      def has_locales?
        locales.present?
      end

      def has_key_column?
        key_column_index.present?
      end

      def key_column_index
        @key_column_index ||= @headers.index(Constant::CSV_WORDING_KEYS_COLUMN)
      end

      def map_row(row:, locales:)
        csv_wording_key = row.field(Constant::CSV_WORDING_KEYS_COLUMN)
        return if csv_wording_key.blank?

        key = Entities::Key.new(label: csv_wording_key)
        locales.map do |locale|
          comment_column_name = "#{Constant::COMMENT_KEY_COLUMN_IDENTIFIER} #{locale}"
          Entities::Translation.new(
            locale: locale,
            key: key,
            value: row.field(locale),
            comment: row.field(comment_column_name)
          )
        end
      end
    end
  end
end