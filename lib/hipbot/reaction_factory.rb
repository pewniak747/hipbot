module Hipbot
  class ReactionFactory
    attr_reader :reactable, :current_description
    private :reactable, :current_description

    def initialize(reactable)
      @reactable = reactable
    end

    def build(restrictions, block, scope_restrictions = {})
      options = scope_restrictions.merge(to_reaction_options(restrictions))
      @current_description = nil
      Reaction.new(reactable, options, block)
    end

    def description(text)
      @current_description = text
    end

    def to_reaction_options(array)
      options = array.last.kind_of?(Hash) ? array.pop : {}
      options.merge({ regexps: array, desc: current_description })
    end
  end
end
