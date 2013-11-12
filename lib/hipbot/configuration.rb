module Hipbot
  class Configuration
    OPTIONS = [
      :adapter, :exception_handler, :helpers, :jid, :join, :logger, :password,
      :plugins, :preloader, :rooms, :status, :storage, :teams, :user
    ]
    attr_accessor *OPTIONS

    def initialize
      self.adapter       = Adapters::Hipchat
      self.exception_handler = Proc.new{ |e| Hipbot.logger.error(e) }
      self.helpers       = Module.new
      self.jid           = ''
      self.join          = :all
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
      @user ||= User.new(name: 'robot', mention: 'robot')
    end
  end
end
