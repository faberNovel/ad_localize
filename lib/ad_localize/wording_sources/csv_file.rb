module AdLocalize
  module WordingSources
    class CSVFile
      attr_reader(:path)

      def initialize(path:)
        @path = path
      end

      def valid?
        File.exist?(@path) && has_key_column? && has_locales?
      end

      def locales
        @locales ||= compute_locales
      end

      def locale_index_mapping
        @locale_index_mapping ||= compute_locale_index_mapping
      end

      private

      def compute_locale_index_mapping
        locales.each_with_object({}) do |locale, acc|
          acc[locale] = headers.index(locale)
        end
      end

      def compute_locales
        return [] unless has_key_column? && wording_key_column_index < headers.size.pred

        headers.slice(wording_key_column_index.succ..-1).compact.reject do |header|
          header.to_s.include?(Constant::COMMENT_KEY_COLUMN_IDENTIFIER)
        end
      end

      def has_locales?
        locales.present?
      end

      def has_key_column?
        wording_key_column_index.present?
      end

      def wording_key_column_index
        @wording_key_column_index ||= headers.index(Constant::CSV_WORDING_KEYS_COLUMN)
      end

      def headers
        @headers ||= CSV.foreach(@path).first
      end
    end
  end
end