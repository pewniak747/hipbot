require 'hipbot'

class MyBot < Hipbot::Bot
  configure do |c|
    c.jid = ENV['HIPBOT_JID']
    c.password = ENV['HIPBOT_PASSWORD']
    c.name = ENV['HIPBOT_NAME']
  end

  # Works for message and response
  # TODO: Reload existing objects? / Full bot restart
  on /^reload (.*)/, global: true do |clazz|
    const = clazz.capitalize.to_sym
    Hipbot.class_eval do
      remove_const const if const_defined? const
    end
    load("./lib/hipbot/" + clazz + ".rb")
    reply('Reloaded')
  end

  on /get (.*)/ do |url|
    get(url) do |http|
      reply("Server responded with code: #{http.response_header.status}")
    end
  end

  on /^wiki (.+)/, global: true do |search|
    search = URI::encode search
    get("http://en.wikipedia.org/w/api.php?action=query&format=json&titles=#{search}&prop=extracts&exlimit=3&explaintext=1&exsentences=2") do |http|
      extracts = JSON.parse http.response.force_encoding 'utf-8'
      extracts['query']['pages'].each do |page|
        reply(page[1]['extract'])
      end
    end
  end

  on /^google (.+)/, global: true do |search|
    search = URI::encode search
    get("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&safe=off&q=#{search}") do |http|
      extracts = JSON.parse http.response.force_encoding 'utf-8'
      extracts['responseData']['results'].each do |page|
        reply("#{page['url']} - #{page['titleNoFormatting']}")
      end
    end
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

  on /help|commands/ do
    commands = []
    bot.reactions.each do |r|
      commands << r.regexp
    end
    reply(commands.join("\n"))
  end

  on /^rand (.*)/, global: true do |message|
    options = message.split(',').map { |s| s.strip }
    rsp = options[rand(options.length)]
    reply("And the winner is... #{rsp}") if rsp
  end

  on /^debug/, global: true do
    reply "Debug " + (Jabber::debug = !Jabber::debug ? 'on' : 'off')
  end
end

MyBot.start!
