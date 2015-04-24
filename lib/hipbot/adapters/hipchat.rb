require 'hipbot/adapters/xmpp'
require 'hipbot/adapters/hipchat/client'

module Hipbot
  module Adapters
    class Hipchat < XMPP
      include Hipbot::Adaptable
    end
  end
end
