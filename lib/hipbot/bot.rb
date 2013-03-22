module Hipbot
  class Bot < Reactable
    attr_accessor :configuration, :connection

    CONFIGURABLE_OPTIONS = [:name, :jid, :password, :adapter, :helpers, :teams, :rooms]
    delegate *CONFIGURABLE_OPTIONS, to: :configuration
    alias_method :to_s, :name

    def initialize
      super
      self.configuration = Configuration.new.tap(&self.class.configuration)
      self.class.reactions.each do |opts|
        on(*opts[0], &opts[-1])
      end
      extend(self.adapter || ::Hipbot::Adapters::Hipchat)
    end

    def react sender, room, message
      matches = matching_reactions(sender, room, message)
      matches.first.invoke(sender, room, message) if matches.size > 0
    end

    class << self
      def default &block
        @default_reaction = [[/(.*)/], block]
      end

      def configure &block
        @configuration = block
      end

      def reactions
        r = super || []
        @default_reaction ? r + [ @default_reaction ] : r
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
