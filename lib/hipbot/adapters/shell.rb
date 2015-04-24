module Hipbot
  module Adapters
    class Shell
      include Hipbot::Adaptable

      attr_accessor :connection

      def start!
        EM.open_keyboard(KeyboardHandler, self)
      end

      module KeyboardHandler
        include EM::Protocols::LineText2
        include Cache

        def initialize adapter
          adapter.connection = self
        end

        attr_cache :user do
          Hipbot::User.find_or_create_by(name: 'Shell User')
        end

        def receive_line data
          Hipbot.react(user, nil, data.strip)
        end
      end
    end
  end
end
