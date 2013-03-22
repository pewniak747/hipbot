module Hipbot
  class Bot < Reactable
    attr_accessor :configuration, :connection
    cattr_accessor :default_reaction

    CONFIGURABLE_OPTIONS = [:name, :jid, :password, :adapter, :helpers, :teams, :rooms]
    delegate *CONFIGURABLE_OPTIONS, to: :configuration
    alias_method :to_s, :name

    def initialize
      super
      self.configuration = Configuration.new.tap(&self.class.configuration)
      on(*default_reaction[0], &default_reaction[-1]) if default_reaction.present?
      extend(self.adapter || ::Hipbot::Adapters::Hipchat)
    end

    def react sender, room, message
      matches = matching_reactions(sender, room, message)
      matches.first.invoke(sender, room, message) if matches.size > 0
    end

    class << self
      def default &block
        @@default_reaction = [[/(.*)/], block]
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

    def matching_reactions sender, room, message
      self.reactions.select { |r| r.match?(sender, room, message) }
    end
  end
end
