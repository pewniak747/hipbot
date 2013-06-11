module Hipbot
  module Adapters
    module Telnet
      class Connection < EM::Connection
        def initialize
          Hipbot.connection = self
        end

        def receive_data(data)
          sender, room, message = data.strip.split(':')
          Hipbot.react(sender, room, message)
        end
      end
    end
  end
end

