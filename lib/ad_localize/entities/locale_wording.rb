module AdLocalize
  module Entities
    class LocaleWording
      attr_reader :locale, :is_default, :singulars, :plurals, :adaptives, :info_plists

      def initialize(locale:, is_default:)
        @locale = locale
        @is_default = is_default
        @singulars = []
        @info_plists = []
        @plurals = Hash.new { |hash, key| hash[key] = [] }
        @adaptives = Hash.new { |hash, key| hash[key] = [] }
      end

      def add_wording(key:, value:, comment:)
        wording = SimpleWording.new(key:, value:, comment:)

        case key.type
        when Parsers::KeyParser::WordingType::PLURAL
          @plurals[key.label].append(wording)
        when Parsers::KeyParser::WordingType::ADAPTIVE
          @adaptives[key.label].append(wording)
        when Parsers::KeyParser::WordingType::INFO_PLIST
          @info_plists.append(wording)
        else
          @singulars.append(wording)
        end
      end

      def to_s
        "Locale\nis default: #{is_default}\n==========\n" +
        "Singulars\n#{singulars}\n==========\n" +
        "InfoPlists\n#{info_plists}\n==========\n" +
        "Plurals\n#{plurals}\n==========\n" +
        "Adaptives\n#{adaptives}\n==========\n"
      end
    end
  end
end