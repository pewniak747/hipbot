module Hipbot
  module Adapters
    module Hipchat
      class Connection
        attr_reader :users, :rooms

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

        def send_to_user(user_name, message)
          user = @users[user_name]
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
          @rooms ||= {}
          @client.get_rooms.each do |r|
            @rooms[r[:item].iname] ||= Room.new(
              @bot,
              r[:item].jid,
              r[:item].iname,
              r[:details]['topic']
            )
          end
          true
        end

        def initialize_users
          @users ||= {}
          @client.get_users.each do |v|
            @users[v[:item].iname] ||= User.new(
              @bot,
              v[:item].jid,
              v[:item].iname,
              v[:vcard]['EMAIL/USERID'],
              v[:item].attributes['mention_name'],
              v[:vcard]['TITLE'],
              v[:vcard]['PHOTO']
            )
          end
          true
        end

        def join_rooms
          if @rooms.empty?
            Jabber::debuglog "No rooms to join"
            return false
          end
          @rooms.each do |_, room|
            @client.join(room.id)
          end
          true
        end

        def exit_all_rooms
          @rooms.each do |_, room|
            @client.exit(room.id, 'bye bye!')
          end
        end

        def initialize_callbacks
          @client.on_message do |room_jid, user_name, message|
            room = find_by_id(@rooms, room_jid)
            next if room.blank?
            room.topic = message.subject if message.subject.present?
            next if user_name == @bot.name || message.body.blank?
            Jabber::debuglog "[#{Time.now}] <#{room.name}> #{user_name}: #{message.body}"
            begin
              @bot.react(user_name, room, message.body)
            rescue => e
              Jabber::debuglog e.inspect
              e.backtrace.each do |line|
                Jabber::debuglog line
              end
            end
          end

          @client.on_private_message do |user_jid, message|
            user = find_by_id(@users, user_jid)
            next if user.blank? || user.name == @bot.name
            if message.body.nil?
              # if message.active?
              # elsif message.inactive?
              # elsif message.composing?
              # elsif message.gone?
              # elsif message.paused?
              # end
            else
              @bot.react(user.name, nil, message.body)
            end
          end

          @client.on_invite do |room_jid, user_name, room_name, topic|
            @rooms[room_name] = Room.new(@bot, room_jid, room_name, topic)
            @client.join(room_jid)
          end

          @client.on_presence do |room_jid, user_name, pres|
            room = find_by_id(@rooms, room_jid)
            next if room.blank? || user_name.blank?
            if pres == 'unavailable'
              if user_name == @bot.name
                @rooms.delete(room.name)
              else
                room.users.delete(user_name)
              end
            elsif pres.blank? && room.users.exclude?(user_name)
              room.users << user_name
            end
          end

          @client.activate_callbacks
        end

        def find_by_id elements, id
          elem = elements.find{ |k, v| v[:id] == id }
          if elem.nil?
            Jabber::debuglog "Unknown element id: '#{id}'"
            return false
          end
          elem.last
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
