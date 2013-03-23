module Hipbot
  class Reactable
    attr_accessor :defined_reactions

    def initialize
      self.defined_reactions = []
      self.class.reactions.each do |opts|
        on(*opts[0], &opts[-1])
      end
    end

    def on *regexps, &block
      self.defined_reactions << to_reaction(regexps, block)
    end

    class << self
      def on *regexps, &block
        @reactions ||= []
        @reactions << [regexps, block]
      end

      def reactions
        @reactions || []
      end

      def default &block
        @default_reaction = [[/(.*)/], block]
      end

      def default_reaction
        @default_reaction
      end
    end

    private

    def default_reactions
      @default_reactions ||= begin
        if reaction = self.class.default_reaction
          [ to_reaction(reaction[0], reaction[-1]) ]
        else
          []
        end
      end
    end

    def to_reaction(regexps, block)
      options = regexps[-1].kind_of?(Hash) ? regexps.pop : {}
      Reaction.new(reaction_target, regexps, options, block)
    end

    def reaction_target
      self
    end
  end
end
