module Hipbot
  module Callbacks
    class PrivateMessage < Base
      def initialize user_id, message
        with_user(user_id) do |user|
          return if ignore_message?(user, message)
          Hipbot.react(user, nil, message.body)
        end
      end

      protected

      def ignore_message? sender, message
        message.body.blank? || sender.myself?
      end
    end
  end
end
