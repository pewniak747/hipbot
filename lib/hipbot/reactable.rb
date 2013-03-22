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
    end

    private

    def to_reaction(regexps, block)
      options = regexps[-1].kind_of?(Hash) ? regexps.pop : {}
      Reaction.new(self, regexps, options, block)
    end
  end
end
