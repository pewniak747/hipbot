module Hipbot
  module Reactable
    def on *params, &block
      scope *params do
        reactions << to_reaction(params, block)
      end
    end

    def default *params, &block
      scope *params do
        default_reactions << to_reaction(params, block)
      end
    end

    def scope *params, &block
      options_stack << reaction_factory.to_reaction_options(params)
      yield
      options_stack.pop
    end

    def desc(text)
      reaction_factory.description(text)
    end

    def reactions
      @reactions ||= []
    end

    def default_reactions
      @default_reactions ||= []
    end

    protected

    def to_reaction params, block
      reaction_factory.build(params, block, scope_options)
    end

    def scope_options
      options_stack.inject { |all, h| all.merge(h) }
    end

    def options_stack
      @options_stack ||= []
    end

    def reaction_factory
      @reaction_factory ||= ReactionFactory.new(self)
    end
  end
end
