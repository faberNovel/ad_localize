module AdLocalize
  module Outputs
    class OutputFacade
      def initialize(strategies: [FSStrategy.new, PrintStrategy.new])
        @strategies = Array(strategies).each_with_object({}) do |strategy, acc|
          acc[strategy.type] = strategy
        end
      end

      def write(output_type:, content:, **args)
        case output_type
        when :file_system
          @strategies[:file_system].write(path: args[:path], content: content)
        when :print
          @strategies[:print].write(content: content)
        else
          raise ArgumentError.new('unknown output type')
        end
      end
    end
  end
end