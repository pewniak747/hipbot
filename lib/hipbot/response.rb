module Hipbot
  class Response < Struct.new(:reaction, :room, :message)
    delegate :sender, :recipients, :body, :to => :message
    delegate :bot, :to => Hipbot

    include Helpers

    def initialize reaction, room, message
      super
      extend(bot.helpers)
    end

    def invoke arguments
      instance_exec(*arguments, &reaction.block)
    rescue Exception => e
      bot.logger.error(e)
      instance_exec(e, &bot.error_handler)
    end

    private

    def reply message, room = self.room
      bot.logger.info("REPLY in #{room}: #{message}")
      room.nil? ? bot.send_to_user(sender, message) : bot.send_to_room(room, message)
    end

    def plugin
      reaction.klass.instance
    end
  end
end
