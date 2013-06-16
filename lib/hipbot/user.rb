module Hipbot
  class User
    def send_message message
      Hipbot.send_to_user name, message
    end

    def mention
      attributes['mention'] || name.delete(' ')
    end

    def first_name
      name.split.first
    end
  end
end
