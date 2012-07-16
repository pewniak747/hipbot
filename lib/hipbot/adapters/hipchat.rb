module Hipbot
  module Adapters
    module Hipchat
      extend ActiveSupport::Concern
      def reply room, message
        connection.deliver("friend@example.com", "message")
      end

      class Connection
        def initialize bot
          @bot = bot
          @bot.connection = self

          @jabber = Jabber::Simple.new(bot.jid, bot.password)
          ::EM::add_periodic_timer(1) do
            @jabber.received_messages.each do |message|
              @bot.tell('someone', 'somewhere', message.body)
            end
            puts "tick"
          end
        end

        def deliver room, message
          puts("replied - #{message}")
        end
      end

      module ClassMethods
        def start!
          ::EM::run do
            Connection.new(self.new)
          end
        end
      end
    end
  end
end

