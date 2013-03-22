module Hipbot
  class Bot < Reactable
    attr_accessor :configuration, :connection

    CONFIGURABLE_OPTIONS = [:name, :jid, :password, :adapter, :helpers, :plugins, :teams, :rooms]
    delegate *CONFIGURABLE_OPTIONS, to: :configuration
    alias_method :to_s, :name

    def initialize
      super
      self.configuration = Configuration.new.tap(&self.class.configuration)
      extend(self.adapter || ::Hipbot::Adapters::Hipchat)
    end

    def reactions
      defined_reactions + plugin_reactions + default_reactions
    end

    def react sender, room, message
      matches = matching_reactions(sender, room, message)
      matches.first.invoke(sender, room, message) if matches.size > 0
    end

    class << self
      def default &block
        @default_reaction = [[/(.*)/], block]
      end

      def default_reaction
        @default_reaction
      end

      def configure &block
        @configuration = block
      end

      def configuration
        @configuration || Proc.new{}
      end

      def start!
        new.start!
      end
    end

    private

    def plugin_reactions
      included_plugins.map(&:defined_reactions).flatten
    end

    def included_plugins
      @included_plugins ||= begin
        Array(plugins).map do |klass|
          klass.new(self)
        end
      end
    end

    def default_reactions
      @default_reactions ||= begin
        if reaction = self.class.default_reaction
          [ to_reaction(reaction[0], reaction[-1]) ]
        else
          []
        end
      end
    end

    def matching_reactions sender, room, message
      reactions.select { |r| r.match?(sender, room, message) }
    end
  end
end
