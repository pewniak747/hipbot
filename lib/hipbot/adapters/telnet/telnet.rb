module Hipbot
  module Adapters
    module Telnet
      def reply room, message
        connection.send_data("#{self}:#{room}:#{message}\n")
      end

      def start!
        ::EM::run do
          ::EM::connect('0.0.0.0', 3001, Connection, self)
        end
      end
    end
  end
end

