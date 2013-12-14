module Hipbot
  class Presence < Struct.new(:sender, :body, :room)
    include Cache

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
