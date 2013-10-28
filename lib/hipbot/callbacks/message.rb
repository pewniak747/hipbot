module Hipbot
  module Callbacks
    class Message < Base
      protected

      def ignore_message? sender, message_body
        message_body.empty? || sender.myself?
      end
    end
  end
end
