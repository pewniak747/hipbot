module Hipbot
class Response < Struct.new(:bot, :reaction, :room, :message_object)

  def invoke arguments
    instance_exec(*arguments, &reaction.block)
  end

  private
  def reply string
    bot.reply(room, string)
  end

  def message
    message_object.body
  end
end
end
