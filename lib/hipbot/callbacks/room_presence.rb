module Hipbot
  module Callbacks
    class RoomPresence < Presence
      attr_accessor :room_id, :user_name_or_mention

      def initialize room_id, user_name_or_mention, presence, role
        self.room_id = room_id
        self.user_name_or_mention = user_name_or_mention
        self.presence = presence

        handle_room_presence
      end

      protected

      def handle_room_presence
        with_room(id: room_id) do |room|
          with_user_by_name_or_mention(user_name_or_mention) do |user|
            Hipbot.logger.info("PRESENCE in ##{room} from #{user}: #{presence}")
            Hipbot.react_to_presence(user, presence, room)

            if offline_presence?
              room.on_leave(user)
            else
              room.on_join(user) if !room.users.include?(user)
              # TODO: Availability status change handling
            end
          end
        end
      end
    end
  end
end
