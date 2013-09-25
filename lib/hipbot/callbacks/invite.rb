module Hipbot
  module Callbacks
    class Invite < Base
      def initialize room_id, user_name, room_name, topic
        room = Room.create(id: room_id, name: room_name, topic: topic)
        Hipbot.join(room)
      end
    end
  end
end
