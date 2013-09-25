module Hipbot
  class Configuration
    OPTIONS = [
      :adapter, :error_handler, :helpers, :jid, :join, :logger, :password,
      :plugins, :preloader, :rooms, :status, :storage, :teams, :user
    ]
    attr_accessor *OPTIONS

    def initialize
      self.adapter       = Adapters::Hipchat
      self.error_handler = Proc.new{}
      self.helpers       = Module.new
      self.jid           = ''
      self.logger        = Logger.new($stdout)
      self.password      = ''
      self.plugins       = Hipbot.plugins
      self.preloader     = Proc.new{}
      self.rooms         = {}
      self.status        = ''
      self.storage       = Storages::Hash
      self.teams         = {}
    end

    def user
      @user ||= User.new(name: 'robot')
    end
  end
end
