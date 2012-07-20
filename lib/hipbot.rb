require 'active_support/all'
require 'eventmachine'
require 'em-http-request'
require 'xmpp4r'
require 'xmpp4r/muc'

# Plugins
require 'google_weather'
require 'mplayer'

require_relative './hipbot/adapters/hipchat'
require_relative './hipbot/adapters/telnet'
require_relative './hipbot/bot'
require_relative './hipbot/configuration'
require_relative './hipbot/message'
require_relative './hipbot/reaction'
require_relative './hipbot/response'
require_relative './hipbot/room'
