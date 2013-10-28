module Hipbot
  module Callbacks
    class RoomMessage < Message
      def initialize room_id, user_name, message_body, topic
        with_sender(room_id, user_name) do |room, user|
          update_topic(room, topic)
          return if ignore_message?(user, message_body)
          Hipbot.react(user, room, message_body)
        end
      end

      protected

      def update_topic room, topic
        room.update_attribute(:topic, topic) unless topic.empty?
      end
    end
  end
end
