module Hipbot
  class User < Collection
    def send_message message
      self.class.bot.send_to_user name, message
    end

    def first_name
      name.split.first
    end
  end
end
