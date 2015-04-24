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

      def with_user_by_name_or_mention name_or_mention
        return if !valid_value?(name_or_mention)

        yield User.where(mention: name_or_mention).first ||
          User.where(name: name_or_mention).first ||
          User.create(name: name_or_mention, mention: name_or_mention)
      end

      private

      def valid_params? params
        params.any?{ |_, v| valid_value?(v) }
      end

      def valid_value? value
        !value.nil? && value.present?
      end
    end
  end
end
