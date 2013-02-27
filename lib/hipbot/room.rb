module Hipbot
  class Room < Collection
    attr_accessor :user_ids

    def initialize *args
      super
      self.user_ids = []
    end

    def set_topic topic
      self.class.bot.set_topic(self, topic)
    end

    def send_message message
      self.class.bot.send_to_room(self, message)
    end

    def users
      user_ids.map{ |id| User[id] }
    end
  end
end
