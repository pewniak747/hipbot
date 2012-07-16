module Hipbot
  module Adapters
    module Hipchat
      extend ActiveSupport::Concern
      def reply room, message
        connection.deliver("friend@example.com", "message")
      end

      class Connection
        def initialize bot
          initialize_bot(bot)
          initialize_rooms

          ::EM::add_periodic_timer(1) do
            puts "tick"
          end
        end

        def deliver room, message
          puts("replied - #{message}")
        end

        private

        def initialize_rooms
          @rooms ||= []
          @rooms = hipchat.rooms
        end

        def initialize_bot bot
          @bot = bot
          @bot.connection = self
        end

        def hipchat
          @hipchat ||= ::HipChat::Client.new(@bot.hipchat_token)
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

