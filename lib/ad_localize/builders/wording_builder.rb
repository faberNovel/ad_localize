module AdLocalize
  module Builders
    class WordingBuilder
      def initialize
        @locale_wording_to_hash = Mappers::LocaleWordingToHash.new
      end

      def build(file_type:, hash_binding:)
        case file_type
        when :json
          @locale_wording_to_hash.map(locale_wording: hash_binding[:locale_wording]).to_json
        when :yml
          @locale_wording_to_hash.map(locale_wording: hash_binding[:locale_wording]).to_yaml
        else
          template = File.read(template_path(file_type: file_type))
          renderer = ERB.new(template, trim_mode: '-')
          renderer.result_with_hash(hash_binding)
        end
      end

      private

      def template_path(file_type:)
        case file_type
        when :info_plist
          platform = 'ios'
          template_name = Constant::IOS_INFO_PLIST_EXPORT_FILENAME
        when :localizable_strings
          platform = 'ios'
          template_name = Constant::IOS_SINGULAR_EXPORT_FILENAME
        when :localizable_stringsdict
          platform = 'ios'
          template_name = Constant::IOS_PLURAL_EXPORT_FILENAME
        when :strings
          platform = 'android'
          template_name = Constant::ANDROID_EXPORT_FILENAME
        when :properties
          platform = 'properties'
          template_name = Constant::PROPERTIES_EXPORT_FILENAME
        else
          raise ArgumentError.new('Unknown file type')
        end
        __dir__ + "/../templates/#{platform}/#{template_name}.erb"
      end
    end
  end
end