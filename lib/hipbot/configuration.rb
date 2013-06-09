module Hipbot
  class Configuration
    attr_accessor *Bot::CONFIGURABLE_OPTIONS

    def initialize
      self.adapter  = Adapters::Hipchat
      self.helpers  = Module.new
      self.jid      = 'changeme'
      self.logger   = Logger.new($stdout)
      self.name     = 'robot'
      self.password = 'changeme'
      self.plugins  = []
      self.rooms    = {}
      self.storage  = Collection
      self.teams    = {}
    end
  end
end
