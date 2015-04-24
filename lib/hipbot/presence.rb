module Hipbot
  class Presence < Struct.new(:sender, :body, :room)
    def for? _
      true
    end

    def private?
      room.nil?
    end
  end
end
