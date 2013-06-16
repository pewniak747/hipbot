require 'xmpp4r/muc/x/muc'
require 'xmpp4r/muc/iq/mucowner'
require 'xmpp4r/muc/iq/mucadmin'
require 'xmpp4r/dataforms'
require 'xmpp4r/roster'
require 'xmpp4r/vcard'

module Jabber
  module MUC
    class HipchatClient

      def initialize(jid)
        @my_jid  = JID.new(jid)

        @stream = Client.new(@my_jid.strip) # TODO: Error Handling
        Jabber::debuglog "Stream initialized"
        @chat_domain = @my_jid.domain

        @presence_cbs = CallbackList.new
        @message_cbs = CallbackList.new
        @private_message_cbs = CallbackList.new
        @invite_cbs = CallbackList.new
      end

      def join(jid, password = nil, opts = { :history => false })
        room_jid = JID.new(jid)
        xmuc = XMUC.new
        xmuc.password = password

        if !opts[:history]
          history = REXML::Element.new('history').tap{ |h| h.add_attribute('maxstanzas','0') }
          xmuc.add_element history
        end

        room_jid.resource = name
        set_presence(:available, room_jid, nil, xmuc) # TODO: Handle all join responses
      end

      def exit(jid, reason = nil)
        room_jid = JID.new(jid)
        Jabber::debuglog "Exiting #{jid}"
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

      def name= resource
        @my_jid.resource = resource
      end

      def on_presence(prio = 0, ref = nil, &block)
        @presence_cbs.add(prio, ref) do |room_jid, user_name, pres_type|
          block.call(room_jid, user_name, pres_type)
          false
        end
      end

      def on_message(prio = 0, ref = nil, &block)
        @message_cbs.add(prio, ref) do |room_jid, user_name, message|
          block.call(room_jid, user_name, message)
          false
        end
      end

      def on_private_message(prio = 0, ref = nil, &block)
        @private_message_cbs.add(prio, ref) do |user_jid, message|
          block.call(user_jid, message)
          false
        end
      end

      def on_invite(prio = 0, ref = nil, &block)
        @invite_cbs.add(prio, ref) do |room_jid, user_name, room_name, topic|
          block.call(room_jid, user_name, room_name, topic)
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

      def send_message(type, jid, text, subject = nil)
        message = Message.new(JID.new(jid), text.to_s)
        message.type = type
        message.from = @my_jid
        message.subject = subject

        @send_thread.join if @send_thread.present? && @send_thread.alive?
        @send_thread = Thread.new {
          @stream.send(message)
          sleep(0.2)
        }
      end

      def connect password
        begin
          @stream.connect
          Jabber::debuglog "Connected to stream"
          @stream.auth(password)
          Jabber::debuglog "Authenticated"
          @muc_browser = MUCBrowser.new(@stream)
          Jabber::debuglog "MUCBrowser initialized"
          @conference_domain = @muc_browser.muc_rooms(@chat_domain).keys.first
          Jabber::debuglog "No conference domain found" if !@conference_domain.present?
          @roster = Roster::Helper.new(@stream) # TODO: Error handling
          @vcard = Vcard::Helper.new(@stream) # TODO: Error handling
          true
        rescue => e
          Jabber::debuglog "Connection failed"
          false
        end
      end

      def activate_callbacks
        @stream.add_presence_callback(150, self) { |presence|
          @presence_cbs.process(presence.from.strip.to_s, presence.from.resource, presence.type.to_s)
        }

        @stream.add_message_callback(150, self) { |message|
          handle_message(message)
        }
        Jabber::debuglog "Callbacks activated"
      end

      def get_rooms
        iq = Iq.new(:get, @conference_domain)
        iq.from = @stream.jid
        iq.add(Discovery::IqQueryDiscoItems.new)

        rooms = []
        @stream.send_with_id(iq) do |answer|
          answer.query.each_element('item') do |item|
            details = {}
            item.first.children.each{ |c| details[c.name] = c.text }
            rooms << {
              :item    => item,
              :details => details
            }
          end
        end
        rooms
      end

      def get_users
        @roster.wait_for_roster
        @roster.items.map do |jid, item|
          {
                jid: item.jid.to_s,
               name: item.iname,
            mention: item.attributes['mention_name'],
          }
        end
      end

      def get_user_details user_jid
        vcard = @vcard.get(user_jid)
        {
          email: vcard['EMAIL/USERID'],
          title: vcard['TITLE'],
          photo: vcard['PHOTO'],
        }
      end

      def deactivate_callbacks
        @stream.delete_presence_callback(self)
        @stream.delete_message_callback(self)
        Jabber::debuglog "Callbacks deactivated"
      end

      private

      def handle_message(message)
        if is_invite?(message)
          room_name = message.children.last.first_element_text('name')
          topic = message.children.last.first_element_text('topic')
          @invite_cbs.process(message.from.strip.to_s, message.from.resource, room_name, topic)
        elsif message.type == :chat
          @private_message_cbs.process(message.from.strip.to_s, message)
        elsif message.type == :groupchat
          @message_cbs.process(message.from.strip.to_s, message.from.resource, message)
        elsif message.type == :error
          false
        end
      end

      def is_invite?(message)
        !message.x.nil? && message.x.kind_of?(XMUCUser) && message.x.first.kind_of?(XMUCUserInvite)
      end

    end
  end
end
