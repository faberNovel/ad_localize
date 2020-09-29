module AdLocalize
  module Outputs
    class FSStrategy
      attr_reader(:type)

      def initialize
        @type = :file_sysyem
      end

      def write(path:, content:)
        raise ArgumentError.new('Missing path') if path.blank?
        path.open("w") { |file| file.puts content }
      end
    end
  end
end