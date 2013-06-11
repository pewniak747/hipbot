module Hipbot
  module Reactable
    def default *params, &block
      scope /(.*)/, *params do
        default_reactions << to_reaction(block)
      end
    end

    def default_reactions
      @default_reactions ||= []
    end

    def desc text = nil
      @description.tap{ @description = text }
    end

    def on *params, &block
      scope *params do
        reactions << to_reaction(block)
      end
    end

    def reactions
      @reactions ||= []
    end

    def scope *params, &block
      options = params.last.kind_of?(Hash) ? params.pop : {}
      options_stack << options.merge({ regexps: params, desc: desc })
      yield
      options_stack.pop
    end

    protected

    def to_reaction block
      current_options = options_stack.inject{ |all, h| all.merge(h) }
      Reaction.new(self, current_options, block)
    end

    def options_stack
      @options_stack ||= []
    end
  end
end
