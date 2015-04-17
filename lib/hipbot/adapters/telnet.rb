module Hipbot
  module Adapters
    class Telnet
      include Hipbot::Adaptable

      attr_accessor :connection

      def start!
        ::EM::start_server('0.0.0.0', 3001, Connection, self)
      end

      def send_to_user user, message
        connection.send_data("#{self}:#{user}:#{message}\n")
      end

      def invite_to_room(*); end
      def join_room(*); end
      def kick_from_room(*); end
      def leave_room(*); end
      def restart!; end
      def send_to_room(*); end
      def set_presence(*); end
      def set_topic(*); end

      class Connection < EM::Connection
        include Cache

        def initialize adapter
          adapter.connection = self
        end

        attr_cache :user do
          Hipbot::User.find_or_create_by(name: 'Telnet User')
        end

        def receive_data data
          message = data.strip
          Hipbot.react(user, nil, message)
        end
      end
    end
  end
end
