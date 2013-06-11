module Hipbot
  class Configuration
    attr_accessor *Bot::CONFIGURABLE_OPTIONS

    def initialize
      self.adapter  = Adapters::Hipchat
      self.error_handler = Proc.new{}
      self.helpers  = Module.new
      self.jid      = 'changeme'
      self.logger   = Logger.new($stdout)
      self.name     = 'robot'
      self.password = 'changeme'
      self.plugins  = Hipbot.plugins
      self.preloader = Proc.new{}
      self.rooms    = {}
      self.storage  = Collection
      self.teams    = {}
    end
  end
end
