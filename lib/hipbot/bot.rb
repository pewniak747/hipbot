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

    def react sender, room, message
      message = Message.new(message, room, sender)
      matches = matching_reactions(message, plugin_reactions)
      matches = matching_reactions(message, default_reactions)[0..0] if matches.empty?
      matches.each(&:invoke)
    end

    def setup
      extend adapter
      Hipbot.bot = self

      User.send(:include, storage)
      Room.send(:include, storage)
      Response.send(:include, helpers)

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

    protected

    def matching_reactions message, reactions
      reactions.map{ |reaction| matching_rection(message, reaction) }.compact
    end

    def matching_rection message, reaction
      match = reaction.match_with(message)
      match.matches? ? match : nil
    end

    def plugin_reactions
      plugins.flat_map{ |p| p.class.reactions }
    end

    def default_reactions
      plugins.flat_map{ |p| p.class.default_reactions }
    end
  end
end
