module Hipbot
class Configuration
  attr_accessor :name, :hipchat_token

  def initialize
    self.name = 'robot'
    self.hipchat_token = 'changeme'
  end
end
end
