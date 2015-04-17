module Hipbot
  module Callbacks
    class Base
      protected

      def with_room params
        yield Room.find_or_create_by(params) if valid_params?(params)
      end

      def with_user params
        yield User.find_or_create_by(params) if valid_params?(params)
      end

      private

      def valid_params? params
        params.any?{ |_, v| !v.nil? && v.present? }
      end
    end
  end
end
