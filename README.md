# Hipbot

[![Build Status](https://secure.travis-ci.org/pewniak747/hipbot.png?branch=master)](http://travis-ci.org/pewniak747/hipbot)
[![Code Climate](https://codeclimate.com/github/pewniak747/hipbot.png)](https://codeclimate.com/github/pewniak747/hipbot)
[![Coverage Status](https://coveralls.io/repos/pewniak747/hipbot/badge.png?branch=master)](https://coveralls.io/r/pewniak747/hipbot)
[![Dependency Status](https://gemnasium.com/pewniak747/hipbot.png)](https://gemnasium.com/pewniak747/hipbot)
[![Gem Version](https://badge.fury.io/rb/hipbot.png)](http://badge.fury.io/rb/hipbot)

Hipbot is a XMPP bot for HipChat, written in ruby & eventmachine.

## Usage

### Install

```
gem install hipbot
```

### Customize

Create `bot.rb` file, subclass `Hipbot::Bot` and customize the responses.

```ruby
require 'hipbot'

class MyCompanyBot < Hipbot::Bot
  configure do |c|
    c.name      = 'robot' # required
    c.jid       = 'changeme@chat.hipchat.com' # required
    c.password  = 'secret' # required
    c.teams     = { vip: ['John', 'Mike'] }
    c.rooms     = { project_rooms: ['Project 1', 'Project 2'] }
  end

  on /^hello/ do
    reply('hello!')
  end

  on /^restart/, from: :vip do
    # ...
    reply('restarting...')
  end

  on /^deploy/, room: :project_rooms do
    # ...
    reply('deploying...')
  end

  default do
    reply('I don\'t understand you!')
  end
end

class PluginClass
  include Hipbot::Plugin

  on /^plugin/ do
    reply('this is from plugin!')
  end
end

MyCompanyBot.start!
```

You can create a response by providing simple regexp:

```ruby
on /^hello/ do
  reply('hello!')
end
```

Responses can pass arguments from regexps:

```ruby
on /my name is (.*)/ do |user_name|
  reply('hello #{user_name}!')
end
```

Define multiple regexps for a response:

```ruby
on /my name is (.*)/, /I am (.*)/ do |name|
  reply('hello #{user_name}!')
end
```

Use :from to only match messages from certain users or user groups defined in configuration

```ruby
configure do |c|
  # ...
  c.teams = { vip: ['John', 'Mike'] }
end

on /status report/, from: ['Tom', 'Dave', :vip] do
  reply('all clear')
end
```

Use :room to only match messages in certain hipchat rooms

```ruby
configure do |c|
  # ...
  c.rooms = { project_rooms: ['Project 1', 'Project 2'] }
end

on /hello/, room: ['Public Room', :project_rooms] do
  reply('hello!')
end
```

Use :global to react to messages that are not sent directly to @robot

```ruby
on /hey I just met you/, global: true do
  reply('and this is crazy...')
end
```

(Use with caution!)

For more examples, check out (https://github.com/pewniak747/hipbot/tree/master/examples)

#### Response helpers

Use http helpers (`get`, `post`, `put`, `delete`) to preform a http request:

```ruby
on /curl (\S+)/ do |url|
  get url do |response|
    reply(response.code)
    reply(response.headers)
    reply(response.body)
  end
end
```

```ruby
on /ping site/ do
  get 'http://example.com', ping: "1" # issues http://example.com?ping=1
end
```

Inside response you have access to following variables:

* `message.body` - sent message
* `message.sender` - user who sent message
* `message.mentions` - array of @mentions inside message, without bot
* `room.name` - name of the current room

You can define your own helpers and use them inside responses like this:

```ruby
module HipbotHelpers
  def project_name
    "#{room.name}-project"
  end
end

class Bot < Hipbot::Bot
  configure do |c|
    # ...
    c.helpers = HipbotHelpers
  end

  on /what's the project called\?/ do
    reply(project_name)
  end
end
```

#### Plugins

To define a plugin, include `Hipbot::Plugin` and add responses like in bot:

```ruby
class GreeterPlugin
  include Hipbot::Plugin
  on /^hello/ do
    reply('hello there!')
  end
end
```

You can gain access to plugin data inside reaction with `plugin` helper:

```ruby
class GreeterPlugin
  include Hipbot::Plugin

  attr_accessor :language

  on /^hello/ do
    case plugin.language
    when :en
      reply("hello!")
    when :pl
      reply("cześć!")
    when :jp
      reply("おはよう！")
    end
  end
end

GreeterPlugin.configure do |c|
  c.language = :jp
end
```

For a collection of open-source plugins, see https://github.com/netguru/hipbot-plugins

### Run

Run hipbot as daemon by saying:

```
hipbot start
```

Run `hipbot` to see all available commands.

## Deploying to Heroku

Create a Procfile & add it to your repo:

```
worker: bundle exec hipbot run
```

```
heroku create
git push heroku master
heroku ps:scale web=0
heroku ps:scale worker=1
```

## TODO:

### Done:

* ~~add extended logging~~
* ~~add plugins support~~
* ~~rewrite SimpleMUCClient~~
* ~~handle private messages callbacks~~
* ~~handle auto joining on room invite~~
* ~~add support for custom helpers~~
  * ~~mentions - returns list of @mentions in message~~
  * ~~sender_name - returns sender's first name~~
  * ~~allow injecting custom module to response object, adding arbitrary methods~~
* ~~handle reconnecting after disconnect/failure~~
* ~~add support for multiple regexps for one response~~
* ~~add support for responses in particular room (`on //, room: ['public'] do ...`)~~
