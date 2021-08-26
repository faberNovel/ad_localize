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
        existing_key_for_label = {}

        values[1..-1].each do |row|
          row_translations = map_row(row: row)
          next if row_translations.blank?

          current_key = row_translations.first.key

          current_label = current_key.label
          existing_key = existing_key_for_label[current_label]

          unless existing_key.nil?
            existing_plural_key = existing_key.label == current_key.label && existing_key.plural? && current_key.singular?
            existing_singular_key = existing_key.label == current_key.label && existing_key.singular? && current_key.plural?
            is_same_key = existing_key.same_as?(key: current_key)
            LOGGER.warn "A plural value already exist for key '#{current_label}'. Remove duplicates." if existing_plural_key
            LOGGER.warn "A singular value already exist for key '#{current_label}'. Remove duplicates." if existing_singular_key
            LOGGER.warn "Some values already exist for key '#{current_label}'. Remove duplicates." if is_same_key
            next if is_same_key || existing_plural_key || existing_singular_key
          end

          existing_key_for_label[current_label] = current_key
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