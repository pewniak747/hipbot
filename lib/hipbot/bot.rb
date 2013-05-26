module Hipbot
  class Bot < Reactable
    attr_accessor :configuration, :connection

    CONFIGURABLE_OPTIONS = [:name, :jid, :password, :adapter, :helpers, :plugins, :teams, :rooms, :logger, :orm]
    delegate *CONFIGURABLE_OPTIONS, to: :configuration
    alias_method :to_s, :name

    def initialize
      super
      self.configuration = Configuration.new.tap(&self.class.configuration)
    end

    def reactions
      self.class.reactions + plugin_reactions + default_reactions
    end

    def react sender, room, message
      Hipbot.logger.info("MESSAGE from #{sender} in #{room}")
      matching_reactions(sender, room, message) do |matches|
        Hipbot.logger.info("REACTION #{matches.first.inspect}")
        matches.first.invoke(sender, room, message)
      end
    end

    def setup
      extend self.adapter
      if self.orm
        User.send(:include, self.orm)
        Room.send(:include, self.orm)
      end
      helpers.module_exec(&self.class.preloader) if self.class.preloader
      Jabber.debug  = true
      Jabber.logger = self.logger
    end

    class << self
      ACCESSORS = { configure: :configuration, on_preload: :preloader, on_error: :error_handler }

      ACCESSORS.each do |setter, getter|
        define_method(setter) do |&block|
          instance_variable_set("@#{getter}", block)
        end

        define_method(getter) do
          instance_variable_get("@#{getter}") || Proc.new{}
        end
      end

      def start!
        ::EM::run do
          instance.setup
          instance.start!
        end
      end
    end

    private

    def plugin_reactions
      included_plugins.map(&:reactions).flatten
    end

    def default_reactions
      self.class.default_reactions + included_plugins.map(&:default_reactions).flatten
    end

    def included_plugins
      @included_plugins ||= Array(plugins).map do |object|
        object.bot = self
        object
      end
    end

    def matching_reactions sender, room, message
      matches = reactions.select{ |r| r.match?(sender, room, message) }
      yield matches if matches.any?
    end
  end
end
