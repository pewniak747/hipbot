module Hipbot
  class Reactable
    include Singleton

    class << self
      def default *params, &block
        scope /(.*)/, *params do
          default_reactions << to_reaction(block)
        end
      end

      def scope *params, &block
        params_stack << params
        yield
        params_stack.pop
      end

      def on *params, &block
        scope *params do
          reactions << to_reaction(block)
        end
      end

      def reactions
        @reactions ||= []
      end

      def default_reactions
        @default_reactions ||= []
      end

      def params_stack
        @params_stack ||= []
      end

      private

      def to_reaction block
        current_options = {}
        current_regexps = []

        params_stack.each do |params|
          options, regexps = params.partition{ |i| i.kind_of? Hash }
          current_options.merge!(options.first) if options.any?
          current_regexps += regexps
        end
        Reaction.new(self, current_regexps, current_options, block)
      end
    end
  end
end
