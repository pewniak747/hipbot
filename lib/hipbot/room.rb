module Hipbot
  class Room < Struct.new(:id, :name, :topic, :users)
    alias_method :to_s, :name

    def initialize(bot, *args)
      super *args, []
      @bot = bot
    end

    def set_topic topic
      @bot.set_topic(self, topic)
    end

    def send_message message
      @bot.send_to_room(self, message)
    end

  end
end
