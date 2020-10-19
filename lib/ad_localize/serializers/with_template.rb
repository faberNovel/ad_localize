module AdLocalize
  module Serializers
    module WithTemplate
      TEMPLATES_DIRECTORY = __dir__ + "/../templates"

      def render(locale_wording:)
        hash_binding = hash_binding(locale_wording: locale_wording)
        return unless hash_binding
        render_template(template_path: template_path, hash_binding: hash_binding)
      end

      def render_template(template_path:, hash_binding:)
        template = File.read(template_path)
        renderer = ERB.new(template, trim_mode: '-')
        renderer.result_with_hash(hash_binding)
      end
    end
  end
end