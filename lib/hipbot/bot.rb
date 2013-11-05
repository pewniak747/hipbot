module Hipbot
  class << self
    attr_accessor :bot, :plugins
    delegate :name, to: :bot

    def plugins
      @plugins ||= []
    end

    def method_missing name, *params, &block
      bot.send(name, *params, &block)
    end
  end

  class Bot
    include Adapter
    include Configurable
    include Singleton
    include Matchable
    extend Reactable

    delegate :name, :to_s, to: :user

    def setup
      Hipbot.bot = self

      User.send(:include, storage)
      Room.send(:include, storage)
      Response.send(:include, helpers)

      helpers.module_exec(&preloader)
      plugins << self
    end

    class << self
      def on_preload &block
        instance.configuration.preloader = block
      end

      def on_error &block
        instance.configuration.error_handler = block
      end

      def start!
        ::EM.error_handler(&instance.configuration.error_handler)
        ::EM.run do
          instance.setup
          begin
            instance.start!
          rescue Exception => e
            instance_exec(e, &instance.configuration.error_handler)
          end
        end
      end
    end
  end
end
