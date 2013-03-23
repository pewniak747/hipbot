module Hipbot
  class Plugin < Reactable
    attr_accessor :bot

    private

    def reaction_target
      bot
    end
  end
end
