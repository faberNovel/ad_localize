module AdLocalize
  module Outputs
    class PrintStrategy
      attr_reader(:type)

      def initialize
        @type = :print
      end

      def write(content:)
        puts content
      end
    end
  end
end