module Hipbot
  class Room < Struct.new(:jid, :name)
    attr_accessor :connection

    def to_s
      name
    end

  end
end
