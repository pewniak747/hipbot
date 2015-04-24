require 'hipbot/adapters/xmpp'
require 'hipbot/adapters/slack/client'

module Hipbot
  module Adapters
    class Slack < XMPP
      add_config_options :slack_api_token
    end
  end
end
