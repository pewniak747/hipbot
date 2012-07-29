module Hipbot
  class Room < Struct.new(:jid, :name)
    attr_accessor :connection, :users
    alias_method :to_s, :name

  end
end
