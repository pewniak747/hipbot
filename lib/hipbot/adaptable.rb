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
  end
end
