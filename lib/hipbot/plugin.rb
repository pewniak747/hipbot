require "singleton"

module Hipbot
  module Plugin
    extend ActiveSupport::Concern

    included do
      extend Reactable
      extend ClassMethods

      include Singleton
      include Helpers

      attr_accessor :response

      delegate :sender, :recipients, :body, :room, :reply, to: :response
      delegate :bot, to: Hipbot

      Hipbot.plugins.unshift(self.instance)
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
