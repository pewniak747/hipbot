module Hipbot
  class Configuration
    OPTIONS = [
      :adapter, :case_insensitive, :exception_handler, :helpers, :join,
      :logger, :password, :plugins, :preloader, :rooms, :status, :storage, :teams, :user
    ]
    attr_accessor *OPTIONS

    def initialize
      self.class.class_eval do
        attr_accessor *Hipbot.adapters.flat_map(&:options).compact
      end

      self.adapter        = Adapters::Hipchat
      self.case_insensitive  = true
      self.exception_handler = proc do |e|
        Hipbot.logger.error(e.message)
        e.backtrace.each { |line| Hipbot.logger.error(line) }
      end
      self.helpers       = Module.new
      self.join          = :all
      self.logger        = Logger.new($stdout)
      self.password      = ''
      self.plugins       = Hipbot.plugins
      self.preloader     = proc {}
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
