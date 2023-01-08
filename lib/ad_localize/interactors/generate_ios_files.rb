module AdLocalize
  module Interactors
    class GenerateIOSFiles
      def call(wording:, options:)
        GenerateInfoPlist.new.call(wording:, options:)
        GenerateLocalizableStrings.new.call(wording:, options:)
        GenerateLocalizableStringsDict.new.call(wording:, options:)
      end
    end
  end
end
