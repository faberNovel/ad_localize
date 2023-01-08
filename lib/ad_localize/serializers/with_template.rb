module AdLocalize
  module Serializers
    module WithTemplate
      TEMPLATES_DIRECTORY = __dir__ + "/../templates"

      def variable_binding(locale_wording:)
        raise 'override me!'
      end

      def translation_to_binding(translation:)
        raise 'override me!'
      end

      def render(locale_wording:)
        variable_binding = variable_binding(locale_wording:)
        return unless variable_binding
        render_template(template_path: template_path, variable_binding: variable_binding)
      end

      def render_template(template_path:, variable_binding:)
        template = File.read(template_path)
        renderer = ERB.new(template, trim_mode: '-')
        renderer.result_with_hash(variable_binding)
      end
    end
  end
end