module Hipbot
  class Response < Struct.new(:bot, :reaction, :room, :message)
    delegate :sender, :recipients, :body, :to => :message
    include Helpers

    def initialize bot, reaction, room, message
      super
      extend(bot.helpers)
    end

    def invoke arguments
      instance_exec(*arguments, &reaction.block)
    rescue Exception => e
      Hipbot.logger.error(e)
      instance_exec(e, &Bot.error_handler)
    end

    private

    def reply message, room = self.room
      Hipbot.logger.info("REPLY in #{room}: #{message}")
      room.nil? ? bot.send_to_user(sender, message) : bot.send_to_room(room, message)
    end

    def plugin
      reaction.klass.instance
    end
  end
end
