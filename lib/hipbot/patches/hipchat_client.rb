require 'xmpp4r/muc/x/muc'
require 'xmpp4r/muc/iq/mucowner'
require 'xmpp4r/muc/iq/mucadmin'
require 'xmpp4r/dataforms'
require 'xmpp4r/roster'
require 'xmpp4r/vcard'

module Jabber
  module MUC
    class HipchatClient

      attr_reader :rooms, :users

      def initialize(my_jid, password)
        @my_jid  = (my_jid.kind_of?(JID) ? my_jid : JID.new(my_jid))

        @stream = Client.new(@my_jid.strip) # TODO: Error Handling
        Jabber::debuglog "Stream initialized"
        @muc_browser = MUCBrowser.new(@stream) # TODO: Error Handling
        Jabber::debuglog "MUCBrowser initialized"

        @chat_domain = @my_jid.domain

        @rooms = {}
        @rooms_lock = Mutex.new
        @users = {}

        @join_cbs = CallbackList.new
        @leave_cbs = CallbackList.new
        @presence_cbs = CallbackList.new
        @message_cbs = CallbackList.new
        @private_message_cbs = CallbackList.new
        @invite_cbs = CallbackList.new

        if connect(password) && get_users && get_rooms
          activate_callbacks
        end
      end

      def join_all_rooms opts = {:history => false}
        if @rooms.empty?
          Jabber::debuglog "No rooms to join"
          return false
        end
        @rooms.each do |room_name, room|
          join(room_name, nil, opts)
        end
      end

      def exit_all_rooms
        @rooms.each do |room_name, room|
          exit(room_name)
        end
      end

      def join(room_name, password = nil, opts = {})
        room_jid = get_room(room_name).clone
        return false unless room_jid

        xmuc = XMUC.new
        xmuc.password = password

        if !opts[:history]
          history = REXML::Element.new('history').tap {|h| h.add_attribute('maxstanzas','0') }
          xmuc.add_element history
        end

        room_jid.resource = name
        set_presence(:available, room_jid, nil, xmuc) # TODO: Handle all join responses
      end

      def exit(room_name, reason = nil)
        room_jid = get_room(room_name)
        return false unless room_jid

        Jabber::debuglog "Exit: #{room_name}"
        set_presence(:unavailable, room_jid, reason)
      end

      def keep_alive password
        if @stream.is_disconnected?
          connect(password)
        end
      end

      def name
        @my_jid.resource
      end

      def send_to_room(room, text)
        room_jid = get_room(room.name)
        return false unless room_jid
        send_message(:groupchat, room_jid, text)
      end

      def send_to_user(user_name, text)
        user_jid = get_user(user_name)
        return false unless user_jid
        send_message(:chat, user_jid, text)
      end

      def on_join(prio = 0, ref = nil, &block)
        @join_cbs.add(prio, ref) do |room_name, user_name, pres_type|
          block.call(room_name, user_name, pres_type)
          false
        end
      end

      def on_leave(prio = 0, ref = nil, &block)
        @leave_cbs.add(prio, ref) do |room_name, user_name, pres_type|
          block.call(room_name, user_name, pres_type)
          false
        end
      end

      def on_presence(prio = 0, ref = nil, &block)
        @presence_cbs.add(prio, ref) do |room_name, user_name, pres_type|
          block.call(room_name, user_name, pres_type)
          false
        end
      end

      def on_message(prio = 0, ref = nil, &block)
        @message_cbs.add(prio, ref) do |room_name, user_name, message_body|
          block.call(room_name, user_name, message_body)
          false
        end
      end

      def on_private_message(prio = 0, ref = nil, &block)
        @private_message_cbs.add(prio, ref) do |user_name, message_body|
          block.call(user_name, message_body)
          false
        end
      end

      def on_invite(prio = 0, ref = nil, &block)
        @invite_cbs.add(prio, ref) do |room_name|
          block.call(room_name)
          false
        end
      end

      def set_presence(type, to = nil, reason = nil, xmuc = nil, &block)
        pres = Presence.new(:chat, reason)
        pres.type = type
        pres.to = to if to
        pres.from = @my_jid
        pres.add(xmuc) if xmuc
        @stream.send(pres) { |r| block.call(r) }
      end

      private

      def send_message(type, to, text)
        message = Message.new(to, text)
        message.type = type
        message.from = @my_jid
        @stream.send(message)
      end

      def handle_presence(pres, call_join_cbs = true)
        user = find_by_jid(@users, pres.from.strip)
        return @presence_cbs.process(nil, user[:name], pres.type.to_s) if user

        user = @users[pres.from.resource]
        room = find_by_jid(@rooms, pres.from.strip)
        return false unless user && room

        if pres.type == :unavailable or pres.type == :error
          @leave_cbs.process(room[:name], user[:name], pres.type.to_s)
        else
          if !room[:users].include? user
            @rooms_lock.synchronize {
              room[:users] << user
            }
            @join_cbs.process(room[:name], user[:name], pres.type.to_s) if call_join_cbs
          else
            @presence_cbs.process(room[:name], user[:name], pres.type.to_s)
          end
        end
      end

      def handle_message(message)
        if is_invite?(message)
          t = Thread.new {
            Thread.current.abort_on_exception = true
            # TODO: Get new room info only
            @rooms_lock.synchronize {
              get_rooms
            }
            room = find_by_jid(@rooms, message.from.strip)
            return false unless room
            @invite_cbs.process(room[:name])
          }
        elsif message.type == :chat
          user = find_by_jid(@users, message.from.strip)
          return false unless user
          if message.body.nil?
            # Chat window states
            if message.active?
            elsif message.inactive?
            elsif message.composing?
            elsif message.gone?
            elsif message.paused?
            end
          else
            @private_message_cbs.process(user[:name], message.body)
          end
        elsif message.type == :groupchat
          user = @users[message.from.resource]
          room = find_by_jid(@rooms, message.from.strip)
          return false unless user && room
          @message_cbs.process(room[:name], user[:name], message.body)
        elsif message.type == :error
          false
        end
      end

      def is_invite?(message)
        !message.x.nil? && message.x.kind_of?(XMUCUser) && message.x.first.kind_of?(XMUCUserInvite)
      end

      def connect password
        @stream.connect # TODO: Error handling
        Jabber::debuglog "Connected to stream"
        @stream.auth(password) # TODO: Error handling
        Jabber::debuglog "Authenticated"
      end

      def activate_callbacks
        @stream.add_presence_callback(150, self) { |presence|
          handle_presence(presence)
        }

        @stream.add_message_callback(150, self) { |message|
          handle_message(message)
        }
        Jabber::debuglog "Callbacks activated"
      end

      def get_rooms
        @conference_domain ||= @muc_browser.muc_rooms(@chat_domain).keys.first
        if !@conference_domain.present?
          Jabber::debuglog "No conference domain found"
          false
        end
        @muc_browser.muc_rooms(@conference_domain).each{ |room_jid, room_name|
          @rooms[room_name] = {
            :name => room_name,
            :jid => room_jid.strip,
            :users => []
          }
        }
        Jabber::debuglog "Got #{@rooms.count} rooms"
        true
      end

      def get_users
        roster = Roster::Helper.new(@stream) # TODO: Error handling
        vcard = Vcard::Helper.new(@stream) # TODO: Error handling
        roster.wait_for_roster
        roster.items.each do |jid, item|
          next if jid == @my_jid.strip
          user = vcard.get(jid)
          @users[item.iname] = {
            :name => item.iname,
            :jid => jid,
            :mention => item.attributes['mention_name'],
            :email => user['EMAIL/USERID'],
            :title => user['TITLE'],
            :photo => user['PHOTO']
          }
        end
        Jabber::debuglog "Got #{@users.count} users"
        true
      end

      def get_room(name, type = :jid)
        if @rooms[name].nil?
          Jabber::debuglog "Unknown room '#{name}'"
          return false
        end
        @rooms[name][type]
      end

      def get_user(name, type = :jid)
        if @users[name].nil?
          Jabber::debuglog "Unknown user '#{name}'"
          return false
        end
        @users[name][type]
      end

      def find_by_jid elements, jid
        elem = elements.find { |k, v| v[:jid] == jid }
        if elem.nil?
          Jabber::debuglog "Unknown element jid '#{jid}'"
          return false
        end
        elem.last
      end

      def deactivate_callbacks
        @rooms = {}
        @users = {}
        @stream.delete_presence_callback(self)
        @stream.delete_message_callback(self)
        Jabber::debuglog "Callbacks deactivated"
      end

    end
  end
end
