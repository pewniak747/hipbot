require 'hipbot/reaction'

module Hipbot
class Bot
  attr_accessor :reactions, :name, :hipchat_token
  def initialize
    self.reactions = []
    self.class.reactions.each do |opts|
      on(opts[0], opts[1], &opts[-1])
    end
    self.class.configuration.call(self) if self.class.configuration
    self.name ||= 'robot'
  end

  def on regexp, options={}, &block
    self.reactions << Reaction.new(self, regexp, options, block)
  end

  def tell message
    matches = matching_reactions(message)
    if matches.size == 1
      match = matches.first
      arguments = match.arguments_for(message)
      instance_exec(*arguments, &match.block)
    elsif matches.size > 1
      reply("I'm not sure what to do...")
    elsif to_me?(message)
      reply("I don't understand \"#{message.gsub(/^@#{name}\s*/, '')}\"")
    end
  end

  def reply message
  end

  def to_me? message
    message =~ /^@#{name}/
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
    @configuration
  end
  end

  private

  def matching_reactions message
    reactions.select { |r| r.match?(message) }
  end
end
end
