module Hipbot
  module Callbacks
    class Base
      protected

      def with_sender room_id, user_name
        room = Room.where(id: room_id).first
        with_user(user_name) do |user|
          yield room, user
        end unless room.nil?
      end

      def with_user user_name
        yield User.find_or_initialize_by(name: user_name)
      end
    end
  end
end
