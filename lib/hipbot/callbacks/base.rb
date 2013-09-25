module Hipbot
  module Callbacks
    class Base
      protected

      def with_sender room_id, user_id
        room = Room.where(id: room_id).first
        with_user(user_id) do |user|
          yield room, user
        end unless room.nil?
      end

      def with_user user_id
        yield User.find_or_initialize_by(id: user_id)
      end
    end
  end
end
