module Hipbot
  class Bot
    attr_accessor :reactions, :configuration, :connection
    CONFIGURABLE_OPTIONS = [:name, :jid, :password, :adapter]
    delegate *CONFIGURABLE_OPTIONS, to: :configuration
    alias_method :to_s, :name

    def initialize
      self.configuration = Configuration.new.tap(&self.class.configuration)
      self.reactions = []
      self.class.reactions.each do |opts|
        on(opts[0], opts[1], &opts[-1])
      end
      extend(self.adapter || ::Hipbot::Adapters::Hipchat)
    end

    def on regexp, options={}, &block
      self.reactions << Reaction.new(self, regexp, options, block)
    end

    def tell sender, room, message
      return if sender == name
      matches = matching_reactions(sender, room, message)
      matches.each do |match|
        match.invoke(sender, room, message)
      end
    end

    def reactions_list
      self.reactions.regexp
    end

    class << self

      def on regexp, options={}, &block
        @reactions ||= []
        @reactions << [regexp, options, block]
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
      all_reactions = reactions + [default_reaction]
      all_reactions.select { |r| r.match?(sender, room, message) }
    end

    def default_reaction
      @default_reaction ||= Reaction.new(self, /.*/, {}, Proc.new {
        reply("I don't understand \"#{message}\"")
      })
    end

  end
end
