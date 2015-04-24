module Hipbot
  module Callbacks
    class RoomTopic < Message
      def initialize room_id, topic
        with_room(id: room_id) do |room|
          Hipbot.logger.info("TOPIC in ##{room}: #{topic}")
          update_topic(room, topic)
        end
      end

      protected

      def update_topic room, topic
        room.update_attribute(:topic, topic)
      end
    end
  end
end
