module Hipbot
  class << self
    attr_accessor :bot, :plugins
    delegate :name, to: :bot

    def plugins
      @plugins ||= []
    end

    def method_missing name, *params, &block
      bot.send(name, *params, &block)
    end
  end

  class Bot
    extend Reactable
    include Singleton

    attr_accessor :configuration, :connection

    CONFIGURABLE_OPTIONS = [:adapter, :error_handler, :helpers, :jid, :logger, :password, :plugins, :preloader, :rooms, :storage, :teams, :user]
    delegate *CONFIGURABLE_OPTIONS, to: :configuration
    delegate :name, to: :user
    alias_method :to_s, :name

    def initialize
      self.configuration ||= Configuration.new
    end

    def reactions
      plugin_reactions + default_reactions
    end

    def react sender, room, message
      logger.info("MESSAGE from #{sender} in #{room}")
      matching_reactions(sender, room, message) do |matches|
        logger.info("REACTION #{matches.first.inspect}")
        matches.first.invoke(sender, room, message)
      end
    end

    def setup
      extend adapter
      Hipbot.bot = self

      User.send(:include, storage)
      Room.send(:include, storage)

      helpers.module_exec(&preloader)
      plugins.append(self)
      Jabber.debug  = true
      Jabber.logger = logger
    end

    class << self
      def configure &block
        instance.configuration = Configuration.new.tap(&block)
      end

      def on_preload &block
        instance.configuration.preloader = block
      end

      def on_error &block
        instance.configuration.error_handler = block
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
      plugins.flat_map{ |p| p.class.reactions }
    end

    def default_reactions
      plugins.flat_map{ |p| p.class.default_reactions }
    end

    def matching_reactions sender, room, message
      matches = reactions.select{ |r| r.match?(sender, room, message) }
      yield matches if matches.any?
    end
  end
end
