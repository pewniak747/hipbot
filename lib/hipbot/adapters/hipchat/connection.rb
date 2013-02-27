module Hipbot
  module Adapters
    module Hipchat
      class Connection
        def initialize bot
          @bot = bot
          @bot.connection = self

          return unless setup_bot
          setup_timers
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
          return unless initialize_client
          initialize_rooms
          initialize_users
          initialize_callbacks
          join_rooms
          set_presence('Hello humans!')
          true
        end

        def initialize_client
          ::Jabber.debug = true
          @client = ::Jabber::MUC::HipchatClient.new(@bot.jid + '/' + @bot.name)
          @client.connect(@bot.password)
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
              email:   v[:vcard]['EMAIL/USERID'],
              mention: v[:item].attributes['mention_name'],
              title:   v[:vcard]['TITLE'],
              photo:   v[:vcard]['PHOTO'],
            }
            User.create(v[:item].jid, v[:item].iname, params)
          end
          true
        end

        def join_rooms
          if Room.empty?
            Jabber::debuglog "No rooms to join"
            return false
          end
          Room.each do |room_jid, _|
            @client.join(room_jid)
          end
          true
        end

        def exit_all_rooms
          Room.each do |room_jid, _|
            @client.exit(room_jid, 'bye bye!')
          end
        end

        def initialize_callbacks
          @client.on_message do |room_jid, user_name, message|
            room = Room[room_jid]
            user = User[user_name]
            next if room.nil? && user.nil?
            room.params.topic = message.subject if message.subject.present?
            next if user_name == @bot.name || message.body.blank?
            Jabber::debuglog "[#{Time.now}] <#{room.name}> #{user_name}: #{message.body}"
            begin
              @bot.react(user, room, message.body)
            rescue => e
              Jabber::debuglog e.inspect
              e.backtrace.each do |line|
                Jabber::debuglog line
              end
            end
          end

          @client.on_private_message do |user_jid, message|
            user = User[user_jid]
            next if user.blank? || user.name == @bot.name
            if message.body.nil?
              # if message.active?
              # elsif message.inactive?
              # elsif message.composing?
              # elsif message.gone?
              # elsif message.paused?
              # end
            else
              @bot.react(user, nil, message.body)
            end
          end

          @client.on_invite do |room_jid, user_name, room_name, topic|
            Room.create(room_jid, room_name, topic: topic)
            @client.join(room_jid)
          end

          @client.on_presence do |room_jid, user_name, pres|
            room = Room[room_jid]
            next if room.blank? || user_name.blank?
            user = User[user_name]
            if pres == 'unavailable'
              if user_name == @bot.name
                room.delete
              elsif user.present?
                room.user_ids.delete(user.id)
              end
            elsif pres.blank? && user.present? && room.user_ids.exclude?(user.id)
              room.user_ids << user.id
            end
          end

          @client.activate_callbacks
        end

        def setup_timers
          ::EM::add_periodic_timer(60) {
            @client.keep_alive(@bot.password) if @client.present?
          }
        end

      end
    end
  end
end
