module Hipbot
  class Reactable
    attr_accessor :reactions

    def initialize
      self.reactions = []
      self.class.reactions.each do |opts|
        on(*opts[0], &opts[-1])
      end
    end

    def on *regexps, &block
      options = regexps[-1].kind_of?(Hash) ? regexps.pop : {}
      self.reactions << Reaction.new(self, regexps, options, block)
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
  end
end
