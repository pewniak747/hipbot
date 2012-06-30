require 'active_support/all'

require 'hipbot/configuration'
require 'hipbot/message'
require 'hipbot/reaction'
require 'hipbot/response'

module Hipbot
class Bot
  attr_accessor :reactions, :configuration
  CONFIGURABLE_OPTIONS = [:name, :hipchat_token]
  delegate *CONFIGURABLE_OPTIONS, to: :configuration

  def initialize
    self.configuration = Configuration.new.tap(&self.class.configuration)
    self.reactions = []
    self.class.reactions.each do |opts|
      on(opts[0], opts[1], &opts[-1])
    end
  end

  def on regexp, options={}, &block
    self.reactions << Reaction.new(self, regexp, options, block)
  end

  def tell sender, room, message
    matches = matching_reactions(sender, room, message)
    if matches.size > 0
      matches[0].invoke(sender, room, message)
    end
  end

  def reply room, message
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
