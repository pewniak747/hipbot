module Jabber
  module MUC

    class MUCClient

      def join(jid, password=nil, opts={})
        if active?
          raise "MUCClient already active"
        end

        @jid = (jid.kind_of?(JID) ? jid : JID.new(jid))
        activate

        # Joining
        pres = Presence.new
        pres.to = @jid
        pres.from = @my_jid
        xmuc = XMUC.new
        xmuc.password = password

        if !opts[:history]
          history = REXML::Element.new( 'history').tap {|h| h.add_attribute('maxstanzas','0') }
          xmuc.add_element history
        end

        pres.add(xmuc)

        # We don't use Stream#send_with_id here as it's unknown
        # if the MUC component *always* uses our stanza id.
        error = nil
        @stream.send(pres) { |r|
          if from_room?(r.from) and r.kind_of?(Presence) and r.type == :error
            # Error from room
            error = r.error
            true
          # type='unavailable' may occur when the MUC kills our previous instance,
          # but all join-failures should be type='error'
          elsif r.from == jid and r.kind_of?(Presence) and r.type != :unavailable
            # Our own presence reflected back - success
            if r.x(XMUCUser) and (i = r.x(XMUCUser).items.first)
              @affiliation = i.affiliation  # we're interested in if it's :owner
              @role = i.role                # :moderator ?
            end

            handle_presence(r, false)
            true
          else
            # Everything else
            false
          end
        }

        if error
          deactivate
          raise ServerError.new(error)
        end

        self
      end

      private
      def activate  # :nodoc:
        @active = true

        # Callbacks
        @stream.add_presence_callback(150, self) { |presence|
          if from_room?(presence.from)
            handle_presence(presence)
            true
          else
            false
          end
        }

        @stream.add_message_callback(150, self) { |message|
          # Not sure if this was hipchat or client bug,
          # but this callback didn't allow chat (private) messages since
          # they don't belong to any conference room
          if from_room?(message.from) || is_chat?(message.type)
            handle_message(message)
            true
          else
            false
          end
        }
      end

      def is_chat?(type)
        type == :chat
      end

      def send(stanza, to = nil)
        if stanza.kind_of? Message
          stanza.type = to || stanza.to ? :chat : :groupchat
        end
        stanza.from = @my_jid
        # We don't want to override existing message JID
        stanza.to = JID.new(jid.node, jid.domain, to) if stanza.to.nil?
        @stream.send(stanza)
      end

    end

    class SimpleMUCClient < MUCClient

      def say(text, jid = nil)
        send(Message.new(jid, text))
      end

      private

      def handle_message(msg)
        super

        time = Time.now # Hipchat doesn't provide time stamp for message elements
        msg.each_element('x') { |x|
          if x.kind_of?(Delay::XDelay)
            time = x.stamp
          end
        }
        sender_nick = msg.from.resource


        if msg.subject
          @subject = msg.subject
          @subject_block.call(time, sender_nick, @subject) if @subject_block
        end

        if msg.body
          if sender_nick.nil?
            @room_message_block.call(time, msg.body) if @room_message_block
          else
            if msg.type == :chat
              # We need to send full jid here (msg.from)
              @private_message_block.call(time, msg.from, msg.body) if @private_message_block
            elsif msg.type == :groupchat
              @message_block.call(time, msg.from.resource, msg.body) if @message_block
            else
              # ...?
            end
          end
        end
      end

    end
  end
end
