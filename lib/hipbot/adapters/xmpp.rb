module Hipbot
  module Adapters
    class XMPP
      include Hipbot::Adaptable

      add_config_options :jid

      attr_accessor :client

      def start!
        self.client = self.class::Client.new.client
      end

      def restart!
        start!
      end

      def invite_to_room(room, users)
        client.invite(user_ids(users), room.id)
      end

      def kick_from_room(room, users)
        client.kick(user_ids(users), room.id)
      end

      def send_to_room(room, message)
        client.send_message(:groupchat, room.id, message)
      end

      def send_to_user(user, message)
        client.send_message(:chat, user.id, message)
      end

      def set_topic(room, topic)
        client.send_message(:groupchat, room.id, nil, topic)
      end

      def set_presence(status, type)
        client.set_presence(status, type)
      end

      def join_room(room)
        client.join(room.id)
      end

      def leave_room(room, reason = '')
        client.exit(room.id, reason)
      end

      protected

      def user_ids users
        Array(users).map(&:id)
      end
    end
  end
end
