module AdLocalize
  module Interactors
    class GenerateIOSFiles
      def call(wording:, export_request:)
        GenerateInfoPlist.new.call(wording:, export_request:)
        GenerateLocalizableStrings.new.call(wording:, export_request:)
        GenerateLocalizableStringsDict.new.call(wording:, export_request:)
      end
    end
  end
end
