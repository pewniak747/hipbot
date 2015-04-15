module Hipbot
  module Callbacks
    class Presence < Base
      attr_accessor :presence

      protected

      def online_presence?
        presence == :available
      end

      def offline_presence?
        presence == :unavailable
      end
    end
  end
end
