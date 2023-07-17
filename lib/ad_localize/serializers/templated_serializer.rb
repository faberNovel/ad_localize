# frozen_string_literal: true
module AdLocalize
  module Serializers
    class TemplatedSerializer
      def initialize(sanitizer:)
        @sanitizer = sanitizer
      end

      def render(locale_wording:)
        variable_binding = variable_binding(locale_wording: locale_wording)
        return unless variable_binding

        render_template(template_path: template_path, variable_binding: variable_binding)
      end

      protected

      TEMPLATES_DIRECTORY = __dir__ + "/../templates"

      def template_path
        raise 'Override me!'
      end

      def variable_binding(locale_wording:)
        raise 'override me!'
      end

      private

      def map_simple_wording(translation:)
        SimpleWordingViewModel.new(
          label: translation.key.label,
          value: @sanitizer.sanitize(value: translation.value),
          comment: translation.comment,
          variant_name: translation.key.variant_name
        )
      end

      def map_compound_wording(label:, translations:)
        variants = translations.map { |_, translation| map_simple_wording(translation: translation) }
        CompoundWordingViewModel.new(label: label, variants: variants)
      end

      def render_template(template_path:, variable_binding:)
        template = File.read(template_path)
        renderer = ERB.new(template, trim_mode: '-')
        renderer.result_with_hash(variable_binding)
      end
    end
  end
end
