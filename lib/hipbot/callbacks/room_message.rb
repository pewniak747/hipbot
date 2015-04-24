module Hipbot
  module Callbacks
    class RoomMessage < Message
      def initialize room_id, user_name_or_mention, message_body
        with_room(id: room_id) do |room|
          with_user_by_name_or_mention(user_name_or_mention) do |user|
            return if ignore_message?(user, message_body)

            Hipbot.react(user, room, message_body)
          end
        end
      end
    end
  end
end
