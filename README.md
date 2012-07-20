# Hipbot

[![Build Status](https://secure.travis-ci.org/pewniak747/hipbot.png?branch=master)](http://travis-ci.org/pewniak747/hipbot)

Hipbot is a bot for HipChat, written in ruby & eventmachine.

This is a work in progress.

## Usage

Install via RubyGems

```
gem install hipbot
```

In bot.rb file, subclass Hipbot::Bot and customize robot responses.

``` ruby
require 'hipbot'

class MyCompanyBot < Hipbot::Bot
  configure do |c|
    c.name = 'robot'
    c.jid = 'changeme@chat.hipchat.com'
    c.password = 'secret'
  end

  # simple reply to '@robot hello!'
  on /^hello.*/ do
    reply('hello!')
  end

  # tasks with arguments: '@robot deploy to production pls'
  on /deploy to (.*) pls/ do |stage|
    reply('deploying to #{stage}!')
    post("http://#{stage}.example.com") do |http|
      reply("deploy server responded with #{http.response_header.status}")
    end
  end

  # global messages
  on /.*hello everyone.*/, global: true do
    reply('hello!')
  end
end

MyCompanyBot.start!
```

Run hipbot as daemon by saying:

```
hipbot start
```

Run `hipbot` to see all available commands.

## TODO:

* add support for custom response helpers
* error handling, reconnecting
