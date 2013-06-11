# example bot that simulates intelligence
# using http://cleverbot.com/ api

require 'hipbot'
require 'cleverbot'
require 'htmlentities'

class CleverHipbot < Hipbot::Bot
  configure do |c|
    c.jid = ENV['HIPBOT_JID']
    c.password = ENV['HIPBOT_PASSWORD']
  end

  cleverbot = ::Cleverbot::Client.new

  on /(.+)/ do |message|
    coder = HTMLEntities.new
    reply(coder.decode(cleverbot.write(message)))
  end
end

CleverHipbot.start!
