module Hipbot
  module Callbacks
    class RoomPresence < Presence
      def initialize room_id, user_name, presence
        self.presence = presence
        room_presence(room_id, user_name)
      end

      protected

      def room_presence room_id, user_name
        with_room(id: room_id) do |room|
          with_user(name: user_name) do |user|
            if offline_presence?
              if user.myself?
                room.destroy
              elsif !user.nil?
                room.users.delete(user)
              end
            elsif online_presence? && !room.users.include?(user)
              room.users << user
            end
          end
        end
      end
    end
  end
end
