module Hipbot
  class Room
    def set_topic topic
      Bot.instance.set_topic(self, topic)
    end

    def send_message message
      Bot.instance.send_to_room(self, message)
    end

    def users
      @users ||= []
    end
  end
end
