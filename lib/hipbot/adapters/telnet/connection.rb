module Hipbot
  module Adapters
    module Telnet
      class Connection < EM::Connection
        def initialize bot
          @bot = bot
          @bot.connection = self
        end

        def receive_data(data)
          sender, room, message = *data.strip.split(':')
          @bot.react(sender, room, message)
        end
      end
    end
  end
end

