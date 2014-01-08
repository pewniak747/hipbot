module Hipbot
  module Callbacks
    class RoomPresence < Presence
      attr_accessor :room_id, :user_name

      def initialize room_id, user_name, presence
        self.presence  = presence
        self.user_name = user_name
        self.room_id   = room_id
        handle_room_presence
      end

      protected

      def handle_room_presence
        with_room(id: room_id) do |room|
          with_user(name: user_name) do |user|
            Hipbot.react_to_presence(user, presence, room)
            if offline_presence?
              room.on_leave(user)
            elsif online_presence? && !room.users.include?(user)
              room.on_join(user)
            else
              # TODO: Availability status change handling
            end
          end
        end
      end
    end
  end
end
