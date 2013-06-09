module Hipbot
  class Bot < Reactable
    attr_accessor :configuration, :connection

    CONFIGURABLE_OPTIONS = [:adapter, :helpers, :jid, :logger, :name, :password, :plugins, :rooms, :storage, :teams]
    delegate *CONFIGURABLE_OPTIONS, to: :configuration
    alias_method :to_s, :name

    def initialize
      super
      self.configuration = Configuration.new.tap(&self.class.configuration)
    end

    def reactions
      plugin_reactions + default_reactions
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

      if self.storage
        User.send(:include, self.storage)
        Room.send(:include, self.storage)
      end

      helpers.module_exec(&self.class.preloader) if self.class.preloader
      plugins.prepend(self.class)
      Jabber.debug  = true
      Jabber.logger = self.logger
    end

    class << self
      alias_method :bot, :instance
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
      plugins.flat_map(&:reactions)
    end

    def default_reactions
      plugins.flat_map(&:default_reactions)
    end

    def matching_reactions sender, room, message
      matches = reactions.select{ |r| r.match?(sender, room, message) }
      yield matches if matches.any?
    end
  end
end
