# Hipbot

[![Build Status](https://secure.travis-ci.org/pewniak747/hipbot.png?branch=master)](http://travis-ci.org/pewniak747/hipbot)

Hipbot is a bot for HipChat, written in ruby & eventmachine.

This is a work in progress.

## Usage

Subclass Hipbot::Bot and customize robot responses.

``` ruby
require 'hipbot'

class MyCompanyBot < Hipbot::Bot
  configure do |c|
    c.hipchat_token = 'secret'
    c.name = 'robot'
  end

  # simple reply to '@robot hello!'
  on /^hello.*/ do
    reply('hello!')
  end

  # tasks with arguments: '@robot deploy to production pls'
  on /deploy to (.*) pls/ do |stage|
    reply('deploying to #{stage}!')
    # deploy instructions
  end

  # global messages
  on /.*hello everyone.*/, global: true do
    reply('hello!')
  end
end

MyCompanyBot.start!
```

## TODO:

* fetching rooms from XMPP api instead of HTTP api
* asynchronous handling of responses waiting for network IO
* add support for custom response helpers
* error handling, reconnecting
* release gem version
