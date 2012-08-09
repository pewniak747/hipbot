module Hipbot
  module Adapters
    module Hipchat
      class Connection
        def initialize bot
          initialize_bot(bot)
          initialize_jabber
          initialize_rooms
          join_rooms
          setup_timers
        end

        def reply room, message
          send_message(room, message)
        end

        def restart!
          leave_rooms
          initialize_rooms
          join_rooms
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
          @jabber.send(::Jabber::Presence.new.set_type(:available))
        end

        def join_rooms
          rooms.each do |room|
            puts "Joining #{room.name}"

            # TODO rewrite (Simple)MUCClient to handle many rooms from one object
            # as there is no need to create distinct objects and callback for each
            # room since all of them have to process same data from @jabber stream.
            # We probably should be able to do something like this:
            # @jabber.set_presence([room1, room2], :available)
            # @jabber.on_event do |time, jid, message| # JID includes sender and room/chat
            # @jabber.send(jid, message)
            room.connection = ::Jabber::MUC::SimpleMUCClient.new(@jabber)
            room.connection.on_message do |time, sender, message|
              puts "#{room.name} > #{time} <#{sender}> #{message}"
              begin
                @bot.tell(sender, room, message)
              rescue => e
                puts e.inspect
              end
            end

            # TODO Get and store all user data from HipChat API
            room.users = []
            room.connection.on_join do |time, nick|
              room.users << nick
            end
            room.connection.on_leave do |time, nick|
              room.users.delete(nick)
            end
            room.connection.join("#{room.jid}/#{@bot.name}", nil, :history => false)
          end

          # TODO handle sending private messages with 'reply'.
          # Simplest way is to add room object for each private chat with param
          # to distinguish whether to use conf or chat domain
          # rooms.first.connection.on_private_message do |time, jid, message|
            # send_message rooms.first, 'hello!', jid

            ## Alternative sending:
            # msg = ::Jabber::Message.new(jid, 'hello!')
            # msg.type = :chat
            # @jabber.send(msg)

            ## We can trigger normal message callback but 'reply' won't work since hipchat PM uses
            ## different jid (user_room@chat.hipchat.com/client_name)
            # rooms.first.connection.message_block.call(time, sender, message)
          # end
        end

        def leave_rooms
          rooms.each do |room|
            room.connection.exit
          end
          @rooms = []
        end

        def setup_timers
          ::EM::add_periodic_timer(10) {
            if !@jabber.nil? && @jabber.is_disconnected?
              initialize_jabber
              join_rooms
            end
          }
        end

        def send_message room, message, jid = nil
          room.connection.say(message, jid)
        end

        def rooms
          @rooms || []
        end
      end
    end
  end
end
