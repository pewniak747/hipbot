module Hipbot
  module Adapters
    module Hipchat
      delegate :reply, to: :connection

      class Connection

        def initialize bot
          initialize_bot(bot)
          initialize_jabber
          initialize_rooms
          join_rooms
        end

        def reply room, message
          for_room room do |room|
            puts("Replied to #{room.name} - #{message}")
            send_message(room, message)
          end
        end

        private

        def initialize_rooms
          @rooms ||= []
          @muc_browser = Jabber::MUC::MUCBrowser.new(@jabber)
          @rooms = @muc_browser.muc_rooms('conf.hipchat.com').map { |jid, name|
            ::Hipbot::Room.new(jid, name)
          }
        end

        def initialize_bot bot
          @bot = bot
          @bot.connection = self
        end

        def initialize_jabber
          @jabber ||= ::Jabber::Client.new(@bot.jid)
          @jabber.connect
          @jabber.auth(@bot.password)
        end

        def join_rooms
          rooms.each do |room|
            puts "joining #{room.name}"
            room.connection = ::Jabber::MUC::SimpleMUCClient.new(@jabber)
            room.connection.on_message do |time, sender, message|
              puts "#{Time.now} <#{sender}> #{message}"
              begin
                @bot.tell(sender, room.name, message)
              rescue => e
                puts e.inspect
              end
            end
            room.connection.join("#{room.jid}/#{@bot.name}", nil, :history => false)
          end
        end

        def for_room room_name
          room = rooms.find { |r| r.name == room_name }
          if room.present?
            yield(room) if block_given?
          end
        end

        def send_message room, message
          room.connection.say(message)
        end

        def rooms
          @rooms || []
        end
      end

      def start!
        ::EM::run do
          ::EM.error_handler do |e|
            puts e.inspect
          end

          Connection.new(self)

          ::EM::add_periodic_timer(10) {
            if !@jabber.nil? && @jabber.is_disconnected?
              initialize_jabber
              join_rooms
            end
          }
        end
      end

    end
  end
end
