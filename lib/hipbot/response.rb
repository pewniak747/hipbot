module Hipbot
class Response < Struct.new(:bot, :reaction, :sender, :room, :message)

  def invoke
    instance_exec(*arguments, &reaction.block)
  end

  private
  def arguments
    reaction.arguments_for(message)
  end

  def reply message
    bot.reply(room, message)
  end

  def processed_message
    reaction.processed_message(message)
  end
end

class NotSureResponse < Response
  def invoke
    reply("I'm not sure what to do...")
  end
end
end
