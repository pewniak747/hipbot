module Hipbot
class Configuration
  attr_accessor :name, :hipchat_token, :jid, :password

  def initialize
    self.name = 'robot'
    self.hipchat_token = 'changeme'
    self.jid = 'changeme'
    self.password = 'changeme'
  end
end
end
