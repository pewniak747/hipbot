class Hipbot
  attr_accessor :reactions
  def initialize
    self.reactions = self.class.reactions 
  end

  def on regexp, &block
    self.reactions << Reaction.new(regexp, block)    
  end

  def tell message
    matches = reactions.select { |r| r.match?(message) }
    if matches.size == 1
      match = matches.first
      arguments = match.arguments_for(message)
      instance_exec(*arguments, &match.block)
    elsif matches.size > 1
      reply("I'm not sure what to do...")
    else
      reply("I don't understand \"#{message}\"")
    end
  end

  class << self
  def on regexp, &block
    @reactions ||= []
    @reactions << Reaction.new(regexp, block)
  end

  def reactions
    @reactions || []
  end
  end
end

class Hipbot::Reaction < Struct.new(:regexp, :block)
  def match? message
    regexp =~ message 
  end

  def arguments_for message
    message.match(regexp)[1..-1]
  end
end
