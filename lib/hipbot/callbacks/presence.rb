module Hipbot
  module Callbacks
    class Presence < Base
      attr_accessor :presence

      def initialize from_id, user_name, presence
        self.presence = presence.to_s

        if user_name.nil?
          lobby_presence(from_id)
        else
          room_presence(from_id, user_name)
        end
      end

      protected

      def lobby_presence user_id
        with_user(user_id) do |user|
          user.update_attribute(:is_online, online?)
        end
      end

      def room_presence room_id, user_name
        with_sender(room_id, user_name) do |room, user|
          if offline?
            if user.myself?
              room.destroy
            elsif !user.nil?
              room.users.delete(user)
            end
          elsif online? && !room.users.include?(user)
            room.users << user
          end
        end
      end

      def online?
        presence.empty?
      end

      def offline?
        presence == 'unavailable'
      end
    end
  end
end
