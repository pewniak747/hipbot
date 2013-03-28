module Hipbot
  module Adapters
    module Hipchat
      class Connection
        def initialize bot
          @bot = bot
          @bot.connection = self

          setup_error_handler && setup_bot && setup_timers
        end

        def restart!
          exit_all_rooms # TODO: Nice quit
          setup_bot
        end

        def send_to_room(room, message)
          @client.send_message(:groupchat, room.id, message)
        end

        def send_to_user(user, message)
          @client.send_message(:chat, user.id, message)
        end

        def set_topic(room, topic)
          @client.send_message(:groupchat, room.id, nil, topic)
        end

        def set_presence(status = nil, type = :available)
          @client.set_presence(type, nil, status)
        end

        private

        def setup_bot
          initialize_client do
            initialize_rooms
            initialize_users
            initialize_callbacks
            join_rooms
            set_presence('Hello humans!')
          end
        end

        def initialize_client
          @client = ::Jabber::MUC::HipchatClient.new(@bot.jid + '/' + @bot.name)
          yield if @client.connect(@bot.password)
        end

        def initialize_rooms
          Room.bot = @bot
          @client.get_rooms.each do |r|
            Room.create(r[:item].jid, r[:item].iname, topic: r[:details]['topic'])
          end
          true
        end

        def initialize_users
          User.bot = @bot
          @client.get_users.each do |v|
            params = {
                email: v[:vcard]['EMAIL/USERID'],
              mention: v[:item].attributes['mention_name'],
                title: v[:vcard]['TITLE'],
                photo: v[:vcard]['PHOTO'],
            }
            User.create(v[:item].jid, v[:item].iname, params)
          end
          true
        end

        def join_rooms
          with_rooms do |rooms|
            rooms.each do |room_jid, _|
              @client.join(room_jid)
            end
          end
        end

        def exit_all_rooms
          with_rooms do |rooms|
            rooms.each do |room_jid, _|
              @client.exit(room_jid, 'bye bye!')
            end
          end
        end

        def initialize_callbacks
          @client.on_message{ |*args| message_callback *args }
          @client.on_private_message{ |*args| private_message_callback *args }
          @client.on_invite{ |*args| invite_callback *args }
          @client.on_presence{ |*args| presence_callback *args }
          @client.activate_callbacks
        end

        def message_callback room_jid, user_name, message
          with_sender(room_jid, user_name) do |room, user|
            room.params.topic = message.subject if message.subject.present?
            return if user_name == @bot.name || message.body.blank?
            Jabber::debuglog "[#{Time.now}] <#{room.name}> #{user_name}: #{message.body}"
            @bot.react(user, room, message.body)
          end
        end

        def invite_callback room_jid, user_name, room_name, topic
          Room.create(room_jid, room_name, topic: topic)
          @client.join(room_jid)
        end

        def presence_callback room_jid, user_name, pres
          with_sender(room_jid, user_name) do |room, user|
            if pres == 'unavailable'
              if user_name == @bot.name
                room.delete
              elsif user.present?
                room.user_ids.delete(user.id)
              end
            elsif pres.blank? && room.user_ids.exclude?(user.id)
              room.user_ids << user.id
            end
          end
        end

        def private_message_callback user_jid, message
          with_user(user_jid) do |user|
            @bot.react(user, nil, message.body) if user.name != @bot.name
          end if message.body.present?
        end

        def with_rooms
          return Jabber::debuglog 'No rooms found' if Room.empty?
          yield Room
        end

        def with_sender room_id, user_id
          room = Room[room_id]
          with_user(user_id) do |user|
            yield room, user
          end if room.present?
        end

        def with_user user_id
          user = User[user_id]
          yield user if user
        end

        def setup_timers
          ::EM::add_periodic_timer(60) do
            @client.keep_alive(@bot.password) if @client.present?
          end
        end

        def setup_error_handler
          ::EM.error_handler do |e|
            Jabber::debuglog e.inspect
            e.backtrace.each do |line|
              Jabber::debuglog line
            end
          end
        end
      end
    end
  end
end
