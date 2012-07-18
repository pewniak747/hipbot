module Hipbot
  module Adapters
    module Telnet
      def reply room, message
        connection.send_data("#{self}:#{room}:#{message}\n")
      end

      class Connection < EM::Connection
        def initialize bot
          @bot = bot
          @bot.connection = self
        end

        def receive_data(data)
          sender, room, message = *data.strip.split(':')
          @bot.tell(sender, room, message)
        end
      end

      def start!
        ::EM::run do
          ::EM::connect('0.0.0.0', 3001, Connection, self)
        end
      end
    end
  end
end

