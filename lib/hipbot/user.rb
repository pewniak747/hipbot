module Hipbot
  class User < Struct.new(:id, :name, :email, :mention, :title, :photo)
    alias_method :to_s, :name

    def initialize bot, *args
      super *args
      @bot = bot
    end

    def send_message message
      @bot.send_to_user name, message
    end

  end
end
