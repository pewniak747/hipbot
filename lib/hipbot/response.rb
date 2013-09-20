module Hipbot
  class Response < Struct.new(:reaction, :message)
    include Helpers

    delegate :sender, :room, to: :message
    delegate :bot, to: Hipbot

    def invoke arguments
      Hipbot.logger.info("REACTION #{reaction.inspect}")
      instance_exec(*arguments, &reaction.block)
      true
    rescue Exception => e
      Hipbot.logger.error(e)
      instance_exec(e, &Hipbot.error_handler)
      false
    end

    def reply message, room = self.room
      room.nil? ? Hipbot.send_to_user(sender, message) : Hipbot.send_to_room(room, message)
    end

    protected

    def method_missing method, *args, &block
      plugin.send(method, *args, &block)
    end

    def plugin
      reaction.plugin.with_response(self)
    end
  end
end
