# frozen_string_literal: true
module AdLocalize
  module Interactors
    class GenerateIOSFiles
      def call(wording:, export_request:)
        GenerateInfoPlist.new.call(wording: wording, export_request: export_request)
        GenerateLocalizableStrings.new.call(wording: wording, export_request: export_request)
        GenerateLocalizableStringsDict.new.call(wording: wording, export_request: export_request)
      end
    end
  end
end
