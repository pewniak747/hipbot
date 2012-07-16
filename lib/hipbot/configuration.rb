module Hipbot
class Configuration
  attr_accessor *Bot::CONFIGURABLE_OPTIONS

  def initialize
    self.name = 'robot'
    self.hipchat_token = 'changeme'
    self.jid = 'changeme'
    self.password = 'changeme'
  end
end
end
