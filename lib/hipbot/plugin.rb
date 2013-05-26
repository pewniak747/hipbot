module Hipbot
  class Plugin < Reactable
    cattr_accessor :bot

    def self.configure
      yield self.instance
    end
  end
end
