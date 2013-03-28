module Hipbot
  module Adapters
    module Hipchat
      def start!
        ::EM::run do
          connection = Connection.new(self)
        end
      end

      def method_missing(sym, *args, &block)
        connection.send sym, *args, &block
      end
    end
  end
end
