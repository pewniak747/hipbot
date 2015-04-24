module Hipbot
  module Callbacks
    class LobbyPresence < Presence
      def initialize user_id, presence
        self.presence = presence

        with_user(id: user_id) do |user|
          Hipbot.logger.info("PRESENCE from #{user}: #{presence}")
          user.update_attribute(:is_online, !offline_presence?)
        end
      end
    end
  end
end
