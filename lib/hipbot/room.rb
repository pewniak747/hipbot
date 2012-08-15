module Hipbot
  class Room < Struct.new(:name, :users)
    alias_method :to_s, :name

  end
end
