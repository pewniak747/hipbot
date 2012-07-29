# Hipbot

[![Build Status](https://secure.travis-ci.org/pewniak747/hipbot.png?branch=master)](http://travis-ci.org/pewniak747/hipbot)

Hipbot is a bot for HipChat, written in ruby & eventmachine.

## Usage

### Install

```
gem install hipbot
```

### Customize

In bot.rb file, subclass Hipbot::Bot and customize robot responses.

``` ruby
require 'hipbot'

class MyCompanyBot < Hipbot::Bot
  configure do |c|
    c.name = 'robot'
    c.jid = 'changeme@chat.hipchat.com'
    c.password = 'secret'
  end

  on /^hello.*/ do
    reply('hello!')
  end
end

MyCompanyBot.start!
```

You can create a response by providing simple regexp:

``` ruby
on /^hello.*/ do
  reply('hello!')
end
```

Responses can pass arguments from regexps:

``` ruby
on /my name is (.*)/ do |user_name|
  reply('hello #{user_name}!')
end
```

Define multiple regexps for a response:

``` ruby
on /my name is (.*)/, /I am (.*)/ do |name|
  reply('hello #{user_name}!')
end
```

Use :from to only match messages from certain users

``` ruby
on /status report/, :from => ['tom', 'dave'] do
  reply('all clear')
end
```

Use :room to only match messages in certain hipchat rooms

``` ruby
on /hello/, :room => ['public'] do
  reply('hello!')
end
```

Use :global to react to messages that are not sent directly to @robot

``` ruby
on /hey I just met you/, :global => true do
  reply('and this is crazy...')
end
```

(Use with caution!)

Use http helpers (`get`, `post`, `put`, `delete`) to preform a http request:

``` ruby
on /curl (\S+)/ do |url|
  get url do |response|
    reply(response.code)
    reply(response.headers)
    reply(response.body)
  end
end
```

``` ruby
on /ping site/ do
  get 'http://example.com', :ping => "1" # issues http://example.com?ping=1
end
```

Inside response you have access to following variables:

* `message` - sent message
* `sender` - user who sent message
* `mentions` - array of @mentions inside message, without bot

### Run

Run hipbot as daemon by saying:

```
hipbot start
```

Run `hipbot` to see all available commands.

## TODO:

* add support for custom helpers
  * ~~mentions - returns list of @mentions in message~~
  * ~~sender_name - returns sender's first name~~
  * allow injecting custom module to response object, adding arbitrary methods
* ~~handle reconnecting after disconnect/failure~~
* handle auto joining on room invite
* ~~add support for multiple regexps for one response~~
* ~~add support for responses in particular room (`on //, :room => ['public'] do ...`)~~
* add extended logging
* add database storage with postgresql adapter
* handle private messages callbacks in the same way
* rewrite SimpleMUCClient
