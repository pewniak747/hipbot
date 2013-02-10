module Hipbot
  module Adapters
    module Hipchat
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

      def method_missing(sym, *args, &block)
        connection.send sym, *args, &block
      end
    end
  end
end
