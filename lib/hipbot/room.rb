module Hipbot
  class Room
    include Cache

    attr_cache :users

    def set_topic topic
      Hipbot.set_topic(self, topic)
    end

    def send_message message
      Hipbot.send_to_room(self, message)
    end

    def invite users
      Hipbot.invite_to_room(self, users)
    end

    def kick users
      Hipbot.kick_from_room(self, users)
    end

    def join
      Hipbot.join_room(self)
    end

    def leave
      Hipbot.leave_room(self)
    end

    def archived?
      !!attributes[:archived]
    end
  end
end
