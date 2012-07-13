require 'hipbot'

class MyBot < Hipbot::Bot
  configure do |c|
    c.hipchat_token = 'secret'
    c.name = 'robot'
  end

  on /weather\s(.*)/ do |city|
    reply("checking weather")
    # http request here
    reply("weather in #{city} - sunny")
  end

  on /^hello.*/ do
    reply('hello!')
  end

  on /deploy to (.*) pls/ do |stage|
    reply("deploying to #{stage}!")
    sleep(3)
    reply("deployed!")
  end

  on /.*hello everyone.*/, global: true do
    reply('hello!')
  end

  on /sleep/, global: true do
    reply("sleeping...")
    sleep(10)
    reply("woke up")
  end

  on /get/, global: true do
    reply("getting...")
    p HTTParty
    r = HTTParty.get('http://google.com').body
    reply("got: #{r}")
  end
end

MyBot.start!
