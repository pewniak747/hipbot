require 'hipbot'

class MyBot < Hipbot::Bot
  configure do |c|
    c.hipchat_token = 'secret'
    c.name = 'robot'
  end

  on /weather\s(.*)/ do |city|
    reply("checking weather for #{city}")
    conditions = ::GoogleWeather.new(city).forecast_conditions.first
    reply("weather in #{city} - #{conditions.condition}, max #{conditions.high}F")
  end

  on /^hello.*/ do
    reply('hello!')
  end

  on /deploy to (.*) pls/ do |stage|
    reply("deploying #{room} to #{stage}!")
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
end

MyBot.start!
