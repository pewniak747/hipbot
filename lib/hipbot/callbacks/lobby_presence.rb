module Hipbot
  module Callbacks
    class LobbyPresence < Presence
      def initialize user_id, presence
        self.presence = presence

        with_user(id: user_id) do |user|
          user.update_attribute(:is_online, online_presence?)
        end
      end
    end
  end
end
