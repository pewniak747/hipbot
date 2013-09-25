module Hipbot
  module Callbacks
    class Presence < Base
      def initialize room_id, user_name, presence
        with_sender(room_id, user_name) do |room, user|
          if user_left?(presence)
            if user.myself?
              room.destroy
            elsif !user.nil?
              room.users.delete(user)
            end
          elsif user_joined?(presence, room, user)
            room.users << user
          end
        end
      end

      protected

      def user_joined? presence, room, user
        presence.empty? && room.users.exclude?(user)
      end

      def user_left? presence
        presence == 'unavailable'
      end
    end
  end
end
