module Hipbot
  module Callbacks
    class Message < PrivateMessage
      def initialize room_id, user_name, message
        with_sender(room_id, user_name) do |room, user|
          update_topic(room, message)
          return if ignore_message?(user, message)
          Hipbot.react(user, room, message.body)
        end
      end

      protected

      def update_topic room, message
        room.update_attribute(:topic, message.subject) unless message.subject.blank?
      end
    end
  end
end
