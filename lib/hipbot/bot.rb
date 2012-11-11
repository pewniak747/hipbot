module Hipbot
  class Bot
    attr_accessor :reactions, :configuration, :connection
    cattr_accessor :default_reaction

    CONFIGURABLE_OPTIONS = [:name, :jid, :password, :adapter, :helpers]
    delegate *CONFIGURABLE_OPTIONS, to: :configuration
    alias_method :to_s, :name

    def initialize
      self.configuration = Configuration.new.tap(&self.class.configuration)
      self.reactions = []
      self.class.reactions.each do |opts|
        on(*opts[0], &opts[-1])
      end
      on(*default_reaction[0], &default_reaction[-1]) if default_reaction.present?
      extend(self.adapter || ::Hipbot::Adapters::Hipchat)
    end

    def on *regexps, &block
      options = regexps[-1].kind_of?(Hash) ? regexps.pop : {}
      self.reactions << Reaction.new(self, regexps, options, block)
    end

    def tell sender, room, message
      return if sender == name
      matches = matching_reactions(sender, room, message)
      if matches.size > 0
        matches.first.invoke(sender, room, message)
      end
    end

    class << self
      def on *regexps, &block
        @reactions ||= []
        @reactions << [regexps, block]
      end

      def default &block
        @@default_reaction = [[/.*/], block]
      end

      def configure &block
        @configuration = block
      end

      def reactions
        @reactions || []
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
