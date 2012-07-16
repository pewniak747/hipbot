module Hipbot
  module Adapters
    module Hipchat
      extend ActiveSupport::Concern
      def reply room, message
        connection.deliver(room, message)
      end

      class Connection
        def initialize bot
          initialize_bot(bot)
          initialize_rooms
          initialize_jabber
          join_rooms

          ::EM::add_periodic_timer(1) do
            puts "tick"
          end
        end

        def deliver room, message
          room = rooms.find { |r| r.name == room }
          if room.present?
            send_message(room, message)
            puts("Replied to #{room} - #{message}")
          else
            puts("Not connected to #{room}")
          end
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

        def initialize_jabber
          @jabber = ::Jabber::Client.new(@bot.jid)
          @jabber.connect
          @jabber.auth(@bot.password)
        end

        def join_rooms
          callback = Proc.new do |time, sender, message|
            @bot.tell(room.name, sender, message)
          end
          rooms.each do |room|
            room.connection = ::Jabber::MUC::SimpleMUCClient.new(@jabber)
            room.connection.on_message(&callback)
            room.connection.join("#{room.xmpp_jid}/#{@bot.name}")
          end
        end

        def send_message room, message
          room.connection.say(message)
        end

        def hipchat
          @hipchat ||= ::HipChat::Client.new(@bot.hipchat_token)
        end

        def rooms
          @rooms || []
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
