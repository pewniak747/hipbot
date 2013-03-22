module Hipbot
  class Plugin < Reactable
    attr_accessor :bot

    def initialize(bot)
      self.bot = bot
      super()
    end

    private

    def reaction_target
      bot
    end
  end
end
