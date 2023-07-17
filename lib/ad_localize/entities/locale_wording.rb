# frozen_string_literal: true
module AdLocalize
  module Entities
    class LocaleWording
      attr_reader :locale, :is_default, :singulars, :plurals, :adaptives, :info_plists

      def initialize(locale:, is_default:)
        @locale = locale
        @is_default = is_default
        @singulars = {} # label => SimpleWording
        @info_plists = {} # label => SimpleWording
        @plurals = Hash.new { |hash, key| hash[key] = {} } # label: String => { variant_name: String => SimpleWording }
        @adaptives = Hash.new { |hash, key| hash[key] = {} } # label: String => { variant_name: String => SimpleWording }
      end

      def add_wording(key:, value:, comment:)
        wording = SimpleWording.new(key: key, value: value, comment: comment)

        case key.type
        when WordingType::PLURAL
          @plurals[key.label][key.variant_name] = wording
        when WordingType::ADAPTIVE
          @adaptives[key.label][key.variant_name] = wording
        when WordingType::INFO_PLIST
          @info_plists[key.label] = wording
        else
          @singulars[key.label] = wording
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
