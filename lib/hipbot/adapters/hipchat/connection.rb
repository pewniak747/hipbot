module Hipbot
  module Adapters
    module Hipchat
      class Connection
        def initialize
          Hipbot.connection = self
          setup_error_handler && setup_bot && setup_timers
        end

        def restart!
          exit_all_rooms # TODO: Nice quit
          setup_bot
        end

        def send_to_room(room, message)
          Hipbot.logger.info("REPLY in #{room}: #{message}")
          @client.send_message(:groupchat, room.id, message)
        end

        def send_to_user(user, message)
          Hipbot.logger.info("REPLY to #{user}: #{message}")
          @client.send_message(:chat, user.id, message)
        end

        def set_topic(room, topic)
          Hipbot.logger.info("TOPIC set in #{room} to '#{topic}'")
          @client.send_message(:groupchat, room.id, nil, topic)
        end

        def set_presence(status = nil, type = :available)
          Hipbot.logger.info("PRESENCE set to #{type} with '#{status}'")
          @client.set_presence(type, nil, status)
        end

        protected

        def setup_bot
          initialize_client do
            initialize_rooms
            initialize_users
            initialize_callbacks
            set_bot_user
            join_rooms
            set_presence('Hello humans!')
          end
        end

        def initialize_client
          @client = ::Jabber::MUC::HipchatClient.new(Hipbot.jid)
          yield if @client.connect(Hipbot.password)
        end

        def initialize_rooms
          @client.get_rooms.each do |room_data|
            room = Room.find_or_create_by(id: room_data[:item].jid)
            room.update_attributes({
                 name: room_data[:item].iname,
                topic: room_data[:details]['topic'],
            })
          end
        end

        def initialize_users
          @client.get_users.each do |user_data|
            user = User.find_or_create_by(id: user_data.delete(:jid))
            user.update_attributes(user_data)

            if user.attributes['email'].nil?
              user.update_attributes(@client.get_user_details(user.id))
            end
          end
        end

        def set_bot_user
          Hipbot.configuration.user = User[Hipbot.jid]
          @client.name = Hipbot.user
        end

        def join_rooms
          with_rooms do |room|
            @client.join(room.id)
          end
        end

        def exit_all_rooms
          with_rooms do |room|
            @client.exit(room.id, 'bye bye!')
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
            room.update_attribute(:topic, message.subject) if message.subject.present?
            return if user_name == Hipbot.name || message.body.blank?
            Hipbot.react(user, room, message.body)
          end
        end

        def invite_callback room_jid, user_name, room_name, topic
          Room.create(id: room_jid, name: room_name, topic: topic)
          @client.join(room_jid)
        end

        def presence_callback room_jid, user_name, pres
          with_sender(room_jid, user_name) do |room, user|
            if pres == 'unavailable'
              if user_name == Hipbot.name
                room.delete
              elsif user.present?
                room.users.delete(user)
              end
            elsif pres.blank? && room.users.exclude?(user)
              room.users << user
            end
          end
        end

        def private_message_callback user_jid, message
          with_user(user_jid) do |user|
            Hipbot.react(user, nil, message.body) if user.name != Hipbot.name
          end if message.body.present?
        end

        def with_rooms
          return Hipbot.logger.error 'No rooms found' if Room.empty?
          Room.each{ |room| yield room }
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
            @client.keep_alive(Hipbot.password) if @client.present?
          end
        end

        def setup_error_handler
          ::EM.error_handler do |e|
            Hipbot.logger.error e.inspect
            e.backtrace.each do |line|
              Hipbot.logger.error line
            end
          end
        end
      end
    end
  end
end
