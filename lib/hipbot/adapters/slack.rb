module Hipbot
  module Adapters
    class Slack < XMPP
      add_config_options :slack_api_token, :conference_host
    end
  end
end
