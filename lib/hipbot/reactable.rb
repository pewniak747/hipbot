module Hipbot
  module Reactable
    include Cache

    attr_cache :reactions, :default_reactions, :options_stack
    attr_cache :reaction_factory do
      ReactionFactory.new(self)
    end

    def on *params, &block
      scope *params do
        reactions << to_reaction(block)
      end
    end

    def default *params, &block
      scope *params do
        default_reactions << to_reaction(block)
      end
    end

    def scope *params, &block
      options_stack << reaction_factory.get_reaction_options(params)
      yield
      options_stack.pop
    end

    def desc text
      reaction_factory.description(text)
    end

    protected

    def to_reaction block
      reaction_factory.build(options_stack, block)
    end
  end
end
