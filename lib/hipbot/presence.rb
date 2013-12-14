module Hipbot
  class Presence < Struct.new(:sender, :body, :room)

    def initialize *args
      super
      Hipbot.logger.info("PRESENCE from #{sender} in #{room}")
    end

    def for? _
      true
    end

    def private?
      room.nil?
    end
  end
end
