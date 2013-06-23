module Hipbot
  module Plugin
    extend ActiveSupport::Concern

    included do
      extend Reactable
      extend ClassMethods

      include Singleton
      include Helpers

      attr_accessor :response

      delegate :sender, :recipients, :body, :room, :to => :response
      delegate :bot, :to => Hipbot

      Hipbot.plugins.prepend(self.instance)
    end

    def reply message, room = self.room
      room.nil? ? Hipbot.send_to_user(sender, message) : Hipbot.send_to_room(room, message)
    end

    module ClassMethods
      def configure
        yield instance
      end

      def with_response response
        instance.tap{ |i| i.response = response }
      end
    end
  end
end
