module AdLocalize
  module Serializers
    module WithTemplate
      def render(locale_wording:)
        variable_binding = variable_binding(locale_wording:)
        return unless variable_binding
        render_template(template_path: template_path, variable_binding: variable_binding)
      end

      # TODO: add sanitizers in DI them in serializer so that sanitize value can be common
      private
      
      TEMPLATES_DIRECTORY = __dir__ + "/../templates"

      def template_path
        raise 'Override me!'
      end

      def variable_binding(locale_wording:)
        raise 'override me!'
      end

      def map_simple_wording(translation:)
        SimpleWordingViewModel.new(
          label: translation.key.label,
          value: sanitize_value(value: translation.value),
          comment: translation.comment,
          variant_name: translation.key.variant_name
        )
      end

      def sanitize_value(value:)
        raise 'Override me!'
      end

      def map_compound_wording(label:, translations:)
        variants = translations.map { |translation| map_simple_wording(translation:) }
        CompoundWordingViewModel.new(label:, variants:)
      end

      def render_template(template_path:, variable_binding:)
        template = File.read(template_path)
        renderer = ERB.new(template, trim_mode: '-')
        renderer.result_with_hash(variable_binding)
      end
    end
  end
end
