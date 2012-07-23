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
    end
  end
end
