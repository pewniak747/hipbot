module Hipbot
  module Adapters
    module Hipchat
      delegate :reply, :users, :rooms, :send_to_room, :send_to_user, to: :connection

      class Connection
        attr_reader :users, :rooms

        def initialize bot
          initialize_bot(bot)
          initialize_client
          @client.join_all_rooms
          initialize_rooms
          initialize_users
          initialize_callbacks
          setup_timers
        end

        def reply room_name, message
          # TODO: use send_to_room / send_to_user instead
          @client.send_to_room room_name, message
        end

        def restart!
          @client.exit_all_rooms
          # TODO: Nice quit
          initialize_client
          @client.join_all_rooms
          initialize_rooms
          initialize_users
          initialize_callbacks
        end

        private

        def initialize_rooms
          @rooms = {}
          @client.rooms.each do |k, v|
            @rooms[k] = Room.new(v[:name], v[:user])
          end
        end

        def initialize_users
          @users = {}
          @client.users.each do |k, v|
            @users[k] = User.new(v[:name], v[:email], v[:mention], v[:title], v[:photo])
          end
        end

        def initialize_bot bot
          @bot = bot
          @bot.connection = self
        end

        def initialize_client
          ::Jabber.debug = true
          @client = ::Jabber::MUC::HipchatClient.new(@bot.jid + '/' + @bot.name, @bot.password)
          @client.set_presence(:available, nil, 'hello humans!')
        end

        def initialize_callbacks
          @client.on_message do |room_name, user, message|
            puts "#{room_name} > #{Time.now} <#{user}> #{message}"
            begin
              with_room(room_name) do |room|
                @bot.tell(user, room, message)
              end
            rescue => e
              puts e.inspect
              e.backtrace.each do |line|
                puts line
              end
            end
          end

          # @client.on_private_message do |user, message|
          #   @client.send_to_user user, 'hello!'
          # end

          # @client.on_invite do |room|
          #   @client.join(room)
          # end

          # @client.on_join do |room, user, pres|
          #   @client.send_to_room room, "Hello, #{user}!"
          # end

          # @client.on_leave do |room, user, pres|
          #   @client.send_to_room room, "Bye bye, #{user}!"
          # end

          # @client.on_presence do |room, user, pres|
          #   if room && pres == 'available'
          #     @client.send_to_room room, "Welcome back, #{user}!"
          #   end
          # end

        end

        def with_room room_name
          room = @rooms.find { |r| r[:name] == room_name }
          yield(room) if room && block_given?
        end

        def setup_timers
          ::EM::add_periodic_timer(10) {
            if @client.present?
              @client.keep_alive(@bot.password)
            end
          }
        end

      end
    end
  end
end
