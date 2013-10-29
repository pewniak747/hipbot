module Hipbot
  module Callbacks
    class PrivateMessage < Message
      def initialize user_id, message_body
        with_user(id: user_id) do |user|
          return if ignore_message?(user, message_body)
          Hipbot.react(user, nil, message_body)
        end
      end
    end
  end
end
