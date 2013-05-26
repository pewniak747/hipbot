module Hipbot
  class Configuration
    attr_accessor *Bot::CONFIGURABLE_OPTIONS

    def initialize
      self.adapter  = Adapters::Hipchat
      self.orm      = Collection
      self.name     = 'robot'
      self.jid      = 'changeme'
      self.password = 'changeme'
      self.teams    = {}
      self.rooms    = {}
      self.helpers  = Module.new
      self.logger   = Logger.new($stdout)
    end
  end
end
