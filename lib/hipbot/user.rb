module Hipbot
  class User
    def send_message message
      Hipbot.send_to_user self, message
    end

    def mention
      attributes[:mention] || name.gsub(/\s+/, '')
    end

    def first_name
      name.split.first
    end

    def myself?
      self == Hipbot.user
    end
  end
end
