module Hipbot
  module Adaptable
    extend ActiveSupport::Concern

    included do
      extend ClassMethods

      Hipbot.adapters.unshift(self)
    end

    module ClassMethods
      attr_reader :options

      def inherited child
        Hipbot.adapters.unshift(child)
      end

      def add_config_options *keys
        @options ||= []
        @options |= keys
      end
    end

    def start!
      logger.error("NOT IMPLEMENTED")
    end

    def invite_to_room(*)
      logger.error("NOT IMPLEMENTED")
    end

    def join_room(*)
      logger.error("NOT IMPLEMENTED")
    end

    def kick_from_room(*)
      logger.error("NOT IMPLEMENTED")
    end

    def leave_room(*)
      logger.error("NOT IMPLEMENTED")
    end

    def restart!
      logger.error("NOT IMPLEMENTED")
    end

    def send_to_room(*)
      logger.error("NOT IMPLEMENTED")
    end

    def set_presence(*)
      logger.error("NOT IMPLEMENTED")
    end

    def set_topic(*)
      logger.error("NOT IMPLEMENTED")
    end
  end
end
