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
    include Adapter
    include Singleton
    extend Reactable

    attr_accessor :configuration, :connection

    delegate *Configuration::OPTIONS, to: :configuration
    delegate :name, :to_s, to: :user

    def initialize
      self.configuration ||= Configuration.new
    end

    def react sender, room, message
      message = Message.new(message, room, sender)
      matching_reactions(message, sender.reactions, plugin_reactions, default_reactions).each(&:invoke)
    end

    def setup
      Hipbot.bot = self

      User.send(:include, storage)
      Room.send(:include, storage)
      Response.send(:include, helpers)

      helpers.module_exec(&preloader)
      plugins.append(self)
      Jabber.debug  = true
      Jabber.logger = logger
    end

    def plugin_reactions
      plugins.flat_map{ |p| p.class.reactions }
    end

    def default_reactions
      plugins.flat_map{ |p| p.class.default_reactions }
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
        ::EM.error_handler(&instance.configuration.error_handler)
        ::EM.run do
          instance.setup
          instance.start!
        end
      end
    end

    protected

    def matching_reactions message, *reaction_sets
      reaction_sets.each do |reactions|
        matches = reactions.map{ |reaction| matching_rection(message, reaction) }.compact
        return matches if matches.any?
      end
      []
    end

    def matching_rection message, reaction
      match = reaction.match_with(message)
      match.matches? ? match : nil
    end

  end
end
