module Hipbot
  module Adapters
    class XMPP
      class Client
        attr_accessor :client

        KEEP_ALIVE_INTERVAL = 60

        def initialize
          initialize_logger

          Hipbot.logger.info("INITIALIZE XMPP Client")
          initialize_client do
            Hipbot.logger.info("INITIALIZE Rooms")
            initialize_rooms
            Hipbot.logger.info("INITIALIZE Users")
            initialize_users
            Hipbot.logger.info("INITIALIZE Bot user")
            initialize_bot_user
            Hipbot.logger.info("INITIALIZE Callbacks")
            initialize_callbacks
            Hipbot.logger.info("INITIALIZE Keep-alive")
            initialize_keep_alive
          end
        end

        protected

        def initialize_logger
          Jabber.logger = Hipbot.logger
          if Hipbot.logger.level == Logger::DEBUG
            Jabber.debug  = true
          end
        end

        def initialize_client
          self.client = ::Jabber::MUC::HipchatClient.new(
            Hipbot.configuration.jid,
            Hipbot.configuration.conference_host,
          )
          yield if client.connect(Hipbot.configuration.password)
        end

        def initialize_rooms
          room_ids = client.get_rooms.map do |room_data|
            room = Room.find_or_create_by(id: room_data.jid)
            room.update_attributes(room_data.attributes)
            room.id
          end
          clean_other_objects(Room, room_ids) if room_ids.any?
        end

        def initialize_users
          user_ids = client.get_users.map do |user_data|
            user = User.find_or_create_by(id: user_data.jid)
            user.update_attributes(user_data.attributes)

            if user.attributes['email'].nil?
              user.update_attributes(client.get_user_details(user.id).attributes)
            end
            user.id
          end
          clean_other_objects(User, user_ids) if user_ids.any?
        end

        def clean_other_objects klass, object_ids
          klass.all.select{ |r| !object_ids.include?(r.id) }.each(&:destroy)
        end

        def initialize_bot_user
          Hipbot.configuration.user = User.find(Hipbot.configuration.jid)
          client.name = Hipbot.user.name
        end

        def initialize_callbacks
          client.on_room_message{ |*args| Callbacks::RoomMessage.new(*args) }
          client.on_private_message{ |*args| Callbacks::PrivateMessage.new(*args) }
          client.on_invite{ |*args| Callbacks::Invite.new(*args) }
          client.on_lobby_presence{ |*args| Callbacks::LobbyPresence.new(*args) }
          client.on_room_presence{ |*args| Callbacks::RoomPresence.new(*args) }
          client.activate_callbacks
        end

        def initialize_keep_alive
          ::EM::add_periodic_timer(KEEP_ALIVE_INTERVAL) do
            client.keep_alive(Hipbot.password) unless client.nil?
          end
        end
      end
    end
  end
end
