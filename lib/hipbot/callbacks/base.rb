module Hipbot
  module Callbacks
    class Base
      protected

      def with_room params
        yield Room.find_or_create_by(params)
      end

      def with_user params
        yield User.find_or_create_by(params)
      end
    end
  end
end
