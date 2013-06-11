module Hipbot
  module Plugin
    include Reactable

    def configure
      yield instance
    end

    class << self
      def extended base
        base.send(:include, Singleton)
        Hipbot.plugins.prepend(base.instance)
      end
    end
  end
end
