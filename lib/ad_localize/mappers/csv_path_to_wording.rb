module AdLocalize
  module Mappers
    class CSVPathToWording
      def map(csv_path:)
        @headers = CSV.foreach(csv_path).first
        return unless valid?(csv_path: csv_path)
        translations = []
        existing_key_for_label = {}

        CSV.foreach(csv_path, headers: true, skip_blanks: true) do |row|
          row_translations = map_row(row: row, locales: locales)
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