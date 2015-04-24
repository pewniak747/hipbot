require "slack"

module Hipbot
  module Adapters
    class Slack < XMPP
      class Client < XMPP::Client
        def initialize
          ::Slack.configure do |config|
            config.token = Hipbot.configuration.slack_api_token
          end
          super
        end

        protected

        def initialize_rooms
          room_ids = ::Slack.client.channels_list["channels"].map do |channel|
            room = Room.find_or_create_by(id: channel["name"])
            room.update_attributes(name: channel["name"])
            room.id
          end

          clean_other_objects(Room, room_ids) if room_ids.any?
        end

        def initialize_users
          user_ids = ::Slack.client.users_list["members"].map do |user_data|
            user = User.find_or_create_by(id: user_data["name"])
            profile_data = user_data["profile"]

            user.update_attributes(
                  name: user_data["real_name"],
               mention: user_data["name"],
                 email: profile_data["email"],
                 title: profile_data["title"],
                 photo: profile_data["image_192"],
                 admin: profile_data["is_admin"],
            )
            user.id
          end

          clean_other_objects(User, user_ids) if user_ids.any?
        end
      end
    end
  end
end
