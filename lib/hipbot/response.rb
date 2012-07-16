module Hipbot
class Response < Struct.new(:bot, :reaction, :room, :message_object)

  def invoke arguments
    instance_exec(*arguments, &reaction.block)
  end

  private
  def reply string
    bot.reply(room, string)
  end

  def error string, options={}
    bot.error(room, string, options)
  end

  def message
    message_object.body
  end

  def sender
    message_object.sender
  end

  def recipients
    message_object.recipients
  end
end
end
