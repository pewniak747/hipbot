module Hipbot
  class Response < Struct.new(:reaction, :message)
    include Helpers

    delegate :sender, :recipients, :body, :room, :to => :message
    delegate :bot, :to => Hipbot

    def invoke arguments
      Hipbot.logger.info("REACTION #{reaction.inspect}")
      instance_exec(*arguments, &reaction.block)
      true
    rescue Exception => e
      Hipbot.logger.error(e)
      instance_exec(e, &Hipbot.error_handler)
      false
    end

    protected

    def reply message, room = self.room
      room.nil? ? Hipbot.send_to_user(sender, message) : Hipbot.send_to_room(room, message)
    end

    def plugin
      reaction.plugin.instance
    end
  end
end
