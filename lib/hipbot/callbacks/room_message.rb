module Hipbot
  module Callbacks
    class RoomMessage < Message
      def initialize room_id, user_name, message_body, topic
        with_room(id: room_id) do |room|
          update_topic(room, topic)
          with_user(name: user_name) do |user|
            return if ignore_message?(user, message_body)
            Hipbot.react(user, room, message_body)
          end
        end
      end

      protected

      def update_topic room, topic
        room.update_attribute(:topic, topic) unless topic.empty?
      end
    end
  end
end
