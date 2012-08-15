module Hipbot
  module Adapters
    module Hipchat
      delegate :reply, :users, :rooms, to: :connection

      class Connection
        attr_reader :users, :rooms

        def initialize bot
          @rooms = {}
          @users = {}
          initialize_bot(bot)
          initialize_client
          initialize_rooms
          initialize_users
          initialize_callbacks
        end

        def reply room_name, message
          @client.send_to_room room_name, message
        end

        private

        def initialize_rooms
          @client.join_all_rooms
          @client.rooms.each do |k, v|
            @rooms[k] = Room.new(v[:name], v[:user])
          end
        end

        def initialize_users
          @client.users.each do |k, v|
            @users[k] = User.new(v[:name], v[:email], v[:mention], v[:title], v[:photo])
          end
        end

        def initialize_bot bot
          @bot = bot
          @bot.connection = self
        end

        def initialize_client
          @client = ::Jabber::MUC::HipchatClient.new(@bot.jid + '/' + @bot.name, @bot.password)
        end

        def initialize_callbacks

          @client.on_message do |room, user, message|
            puts "#{room} > #{time} <#{user}> #{message}"
            begin
              @bot.tell(user, room, message)
            rescue => e
              puts e.inspect
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
      end

      def start!
        ::EM::run do
          ::EM.error_handler do |e|
            puts e.inspect
          end

          Connection.new(self)

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
