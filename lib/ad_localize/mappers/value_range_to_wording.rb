module AdLocalize
  module Mappers
    class ValueRangeToWording
      def map(value_range:)
        values = value_range.values
        analyze_header(first_row: values.first)
        return unless valid_header?

        translations = map_rows(values: values)
        locale_wordings = translations.group_by(&:locale).map do |locale, group|
          Entities::LocaleWording.new(locale: locale, translations: group)
        end
        Entities::Wording.new(locale_wordings: locale_wordings, default_locale: @locale_mapping.keys.first)
      end

      private

      def map_rows(values:)
        translations = []
        validator = Validators::KeyValidator.new

        values[1..-1].each do |row|
          row_translations = map_row(row: row)
          next if row_translations.blank?

          current_key = row_translations.first.key
          next if validator.has_warnings?(current_key)

          translations.concat(row_translations)
        end
        translations
      end

      def analyze_header(first_row:)
        @header = first_row
        @key_index = first_row.index(Constant::CSV_WORDING_KEYS_COLUMN)
        @locale_mapping = {}
        first_row[@key_index.succ..-1].each_index do |relative_index|
          absolute_index = @key_index.succ + relative_index
          next if first_row[absolute_index].blank? || first_row[absolute_index].include?(Constant::COMMENT_KEY_COLUMN_IDENTIFIER)
          @locale_mapping[first_row[absolute_index]] = { key_index: absolute_index }
          comment_column_name = "#{Constant::COMMENT_KEY_COLUMN_IDENTIFIER} #{first_row[absolute_index]}"
          @locale_mapping[first_row[absolute_index]][:comment_index] = first_row.index(comment_column_name)
        end
      end

      def map_row(row:)
        csv_wording_key = row[@key_index]
        return if csv_wording_key.blank?
        key = Entities::Key.new(label: csv_wording_key)
        @locale_mapping.map do |locale, index_mapping|
          comment = index_mapping[:comment_index].nil? ? nil : row[index_mapping[:comment_index]]
          Entities::Translation.new(
            locale: locale,
            key: key,
            value: row[index_mapping[:key_index]],
            comment: comment
          )
        end
      end

      def valid_header?
        @key_index.present? || @locale_mapping.keys.size.positive?
      end
    end
  end
end
