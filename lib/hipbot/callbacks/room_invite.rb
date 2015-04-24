module Hipbot
  module Callbacks
    class RoomInvite < Base
      def initialize room_id, room_name
        return unless Hipbot.configuration.join_on_invite

        with_room(id: room_id, name: room_name) do |room|
          Hipbot.join_room(room)
        end
      end
    end
  end
end
