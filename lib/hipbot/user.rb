module Hipbot
  class User < Struct.new(:name, :email, :mention, :title, :photo)
    alias_method :to_s, :name

  end
end
