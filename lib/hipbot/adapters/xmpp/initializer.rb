module Hipbot
  module Adapters
    class XMPP
      class Initializer
        attr_accessor :client

        KEEP_ALIVE_INTERVAL = 60

        def initialize
          Jabber.debug  = true
          Jabber.logger = Hipbot.logger
          initialize_client do
            initialize_rooms
            initialize_users
            initialize_bot_user
            initialize_callbacks
            initialize_keep_alive
          end
        end

        protected

        def initialize_client
          self.client = ::Jabber::MUC::HipchatClient.new(
            Hipbot.jid,
            Hipbot.conference_host,
          )
          yield if client.connect(Hipbot.password)
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
          Hipbot.configuration.user = User.find_or_create_by(id: Hipbot.jid)
          client.name = Hipbot.user.name
        end

        def initialize_callbacks
          client.on_room_message{ |*args|
            Callbacks::RoomMessage.new(*args)
          }
          client.on_private_message{ |*args|
            Callbacks::PrivateMessage.new(*args)
          }
          client.on_invite{ |*args|
            Callbacks::Invite.new(*args)
          }
          client.on_lobby_presence{ |*args|
            Callbacks::LobbyPresence.new(*args)
          }
          client.on_room_presence{ |*args|
            Callbacks::RoomPresence.new(*args)
          }
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
