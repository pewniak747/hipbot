require "slack"

module Hipbot
  module Adapters
    class Slack < XMPP
      class Client < XMPP::Client
        protected

        def initialize_bot_user
          Hipbot.configuration.user = User.find(Hipbot.configuration.jid)
          client.name = Hipbot.user.name.delete(" ").downcase
          Hipbot.configuration.user.update(mention: client.name)
        end

        def initialize_rooms
          ::Slack.configure do |config|
            config.token = Hipbot.configuration.slack_api_token
          end

          room_ids = ::Slack.client.channels_list["channels"].map do |channel|
            room = Room.find_or_create_by(
              name: channel["name"],
              id: Jabber::JID.new(channel["name"], Hipbot.configuration.conference_host, "hipbot").to_s
            )
            room.id
          end

          clean_other_objects(Room, room_ids) if room_ids.any?
        end

        def initialize_users
          user_ids = client.get_users.map do |user_data|
            user = User.find_or_create_by(id: user_data.jid)
            user.update_attributes(user_data.attributes)
            user.id
          end
          clean_other_objects(User, user_ids) if user_ids.any?
        end
      end
    end
  end
end
