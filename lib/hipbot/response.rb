module Hipbot
class Response < Struct.new(:bot, :reaction, :sender, :room, :message)

  def invoke arguments
    instance_exec(*arguments, &reaction.block)
  end

  private
  def reply message
    bot.reply(room, message)
  end
end
end
