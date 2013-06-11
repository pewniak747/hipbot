module Hipbot
  module Adapters
    module Hipchat
      def start!
        connection = Connection.new
      end

      def method_missing(sym, *args, &block)
        connection.send sym, *args, &block
      end
    end
  end
end
