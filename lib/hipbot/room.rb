module Hipbot
  class Room < Collection
    attr_accessor :user_ids

    def initialize *args
      super
      self.user_ids = []
    end

    def set_topic topic
      Bot.instance.set_topic(self, topic)
    end

    def send_message message
      Bot.instance.send_to_room(self, message)
    end

    def users
      user_ids.map{ |id| User[id] }
    end
  end
end
