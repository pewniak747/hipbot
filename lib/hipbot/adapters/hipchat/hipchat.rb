module Hipbot
  module Adapters
    module Hipchat
      delegate :reply, to: :connection

      def start!
        ::EM::run do
          ::EM.error_handler do |e|
            puts e.inspect
          end

          Connection.new(self)
        end
      end
    end
  end
end
