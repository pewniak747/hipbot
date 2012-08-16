module Hipbot
  module Adapters
    module Hipchat
      delegate :reply, to: :connection

      def start!
        ::EM::run do
          ::EM.error_handler do |e|
            puts e.inspect
            e.backtrace.each do |line|
              puts line
            end
          end

          Connection.new(self)
        end
      end
    end
  end
end
