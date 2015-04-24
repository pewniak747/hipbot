module Hipbot
  module Callbacks
    class Presence < Base
      attr_accessor :presence

      protected

      def offline_presence?
        presence == :unavailable
      end
    end
  end
end
