module Hipbot
  module Adapter
    def start!
      logger.info("STARTING")
      self.connection = adapter.new
      connection.start!
      set_presence(status)
      join_all_rooms
    end

    def restart!
      logger.info("RESTARTING")
      leave_all_rooms
      connection.restart!
    end

    def join_room(room)
      logger.info("JOINING #{room}")
      connection.join_room(room)
    end

    def leave_room(room)
      logger.info("LEAVING #{room}")
      connection.leave_room(room)
    end

    def invite_to_room(room, users)
      logger.info("INVITING to #{room}: #{users}")
      connection.invite_to_room(room, users)
    end

    def kick_from_room(room, users)
      logger.info("KICKING from #{room}: #{users}")
      connection.kick_from_room(room, users)
    end

    def send_to_room(room, message)
      logger.info("REPLY in #{room}")
      connection.send_to_room(room, message)
    end

    def send_to_user(user, message)
      logger.info("REPLY to #{user}")
      connection.send_to_user(user, message)
    end

    def set_topic(room, topic)
      logger.info("TOPIC seting in #{room} to '#{topic}'")
      connection.set_topic(room, topic)
    end

    def set_presence(status, type = :available)
      logger.info("PRESENCE set to #{type} with '#{status}'")
      connection.set_presence(status, type)
    end

    protected

    def join_all_rooms
      Room.each(&:join)
    end

    def leave_all_rooms
      Room.each(&:leave)
    end
  end
end
