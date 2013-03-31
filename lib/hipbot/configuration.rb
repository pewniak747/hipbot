module Hipbot
  class Configuration
    attr_accessor *Bot::CONFIGURABLE_OPTIONS

    def initialize
      self.name     = 'robot'
      self.jid      = 'changeme'
      self.password = 'changeme'
      self.teams    = {}
      self.rooms    = {}
      self.helpers  = Module.new
    end
  end
end
