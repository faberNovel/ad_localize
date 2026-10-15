# frozen_string_literal: true
module AdLocalize
  module Interactors
    class GenerateARB < BaseGenerateFiles
      def initialize
        super(serializer: Serializers::ARBSerializer.new)
      end

      private

      def has_wording?(locale_wording:)
        locale_wording.singulars.any? || locale_wording.plurals.any?
      end

      def output_path(locale_wording:, export_request:)
        locale = Serializers::ARBSerializer.arb_locale(locale_wording.locale)
        export_request.output_dir.join("app_#{locale}.arb")
      end
    end
  end
end
