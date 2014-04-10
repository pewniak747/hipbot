# Hipbot

Hipbot is a XMPP bot for HipChat, written in Ruby with EventMachine.

[![Build Status](https://secure.travis-ci.org/pewniak747/hipbot.png?branch=master)](http://travis-ci.org/pewniak747/hipbot)
[![Code Climate](https://codeclimate.com/github/pewniak747/hipbot.png)](https://codeclimate.com/github/pewniak747/hipbot)
[![Coverage Status](https://coveralls.io/repos/pewniak747/hipbot/badge.png?branch=master)](https://coveralls.io/r/pewniak747/hipbot)
[![Dependency Status](https://gemnasium.com/pewniak747/hipbot.png)](https://gemnasium.com/pewniak747/hipbot)
[![Gem Version](https://badge.fury.io/rb/hipbot.png)](http://badge.fury.io/rb/hipbot)

### Compatibility
Hipbot is tested on:

* Ruby 1.9.3, 2.0.0 and 2.1.0
* JRuby 1.9 mode
* Rubinus

### Dependencies

* daemons >= 1.1.8
* activesupport >= 3.2.12
* eventmachine >= 1.0.3
* em-http-request >= 1.0.3
* xmpp4r ~> 0.5

## Getting started
### Installation

```shell
gem install hipbot
```

### 1 minute setup on heroku

Follow the instructions on [hipbot-example](https://github.com/netguru/hipbot-example).

### Custom setup
Create `bot.rb` file, subclass `Hipbot::Bot` and customize the responses.

```ruby
require 'hipbot'

class MyBot < Hipbot::Bot
  configure do |c|
    c.jid       = 'changeme@chat.hipchat.com'
    c.password  = 'secret'
  end

  on /^hello$/ do
    reply("Hello!")
  end
end

MyBot.start!
```

### Running
Start Hipbot as a daemon by executing:

```shell
hipbot start
```

Run `hipbot` to see all available commands.

Start in shell:

```shell
ruby bot.rb
```

### Behavior
* On start and runtime:
    * Fetches details and presences of all users in Lobby
    * Pings XMPP server every 60 seconds to keep alive
* On new message:
    * Invokes all matching reactions or falls back to default reaction

## Usage
### Configuration
Full configuration example:
```ruby
class MyBot < Hipbot::Bot
  configure do |c|
    # Account JID (required) - see https://hipchat.com/account/xmpp for your JID
    c.jid      = 'changeme@chat.hipchat.com'

    # Account password (required)
    c.password = 'secret'

    # Custom helpers module (optional) - see below for examples
    c.helpers  = MyHipbotHelpers

    # Logger (default: Hipbot::Logger.new($stdout))
    c.logger   = Hipbot::Logger.new($stdout)

    # Initial status message (default: '')
    c.status   = "I'm here to help"

    # Storage adapter (default: Hipbot::Storages::Hash)
    c.storage  = Hipbot::Storages::Hash

    # Predefined room groups (optional)
    c.rooms    = { project_rooms: ['Project 1', 'Project 2'] }

    # Predefined user groups (optional)
    c.teams    = { admins: ['John Smith'] }

    # Auto join criteria (default: :all)
    # Accepted values: :all, :public, :private, :none, "room name"
    c.join     = :private
  end
end
```
### Reaction helpers
Inside the reaction block you have access to following context objects:

* `bot`
* `room`
* `sender`
* `message`
* `reaction`

### Joining rooms
Hipbot will join all accessible rooms by default on startup and invite.

To change auto join method use `join` configuration option:
```ruby
configure do |c|
  # ...
  c.join = :private
end
```
```ruby
configure do |c|
  # ...
  c.join = :none
end
```
```ruby
configure do |c|
  # ...
  c.join = ['Project Room', :public]
end
```
Notice: Archived rooms are always ignored

### Bot presence
Use `bot.set_presence` method to change Hipbot presence:
```ruby
on /^change status$/ do
  bot.set_presence("Hello humans")
end
```
```ruby
on /^go away$/ do
  bot.set_presence("I'm away", :away)
end
```
```ruby
on /^do not disturb$/ do
  bot.set_presence(nil, :dnd)
end
```

### Rooms
Use `Hipbot::Room` for collection of available rooms.
```ruby
on /^list all rooms$/ do
  all_rooms = Hipbot::Room.all.map(&:name)
  reply(all_rooms.join(', '))
end
```
```ruby
on /^get project room JID$/ do
  project_room = Hipbot::Room.find_by(name: 'project room')
  reply(project_room.id)
end
```
Use `room` for current room object (it's `nil` if message is private):
```ruby
on /^where am I\?$/ do
  reply(
    "You are in #{room}\n" +
    "JID: #{room.id}\n" +
    "Topic: #{room.topic}\n" +
    "Users online: #{room.users.count}\n" +
    "Privacy: #{room.privacy}\n" +
    "Hipchat ID: #{room.hipchat_id}\n" +
    "Archived?: #{room.archived ? 'yes' : 'no'}\n" +
    "Guest URL: #{room.guest_url}"
  )
end
```

### Users
Use `Hipbot::User` for collection of all users:
```ruby
on /^list all users$/ do
  all_users = Hipbot::User.all.map(&:name)
  reply(all_users.join(', '))
end
```
```ruby
on /^get John Smith's JID$/ do
  john = Hipbot::Room.find_by(name: 'John Smith')
  reply(john.id)
end
```
Use `sender` for message sender object:
```ruby
on /^who am I\?$/ do
  reply(
    "You are #{sender}\n" +
    "JID: #{sender.id}\n" +
    "Mention: @#{sender.mention}\n" +
    "E-mail: #{sender.email}\n" +
    "Title: #{sender.title}\n" +
    "Photo: #{sender.photo}"
  )
end
```
Use `Room#users` method for online users array:
```ruby
on /^list online users$/ do
  reply room.users.map(&:name).join(', ')
end
```

### Replying
Use `reply` method to send a message.

Reply in the same room / chat:
```ruby
on /^hello$/ do
  reply("Hello!")
end
```
Reply in "help room":
```ruby
on /^I need help$/ do
  help_room = Hipbot::Room.find_by(name: 'help room')
  reply("#{sender} needs help in #{room}", help_room)
end
```

### Private messaging
```ruby
on /^send me private message$/ do
  sender.send_message("Hello, #{sender}")
end
```
```ruby
on /^send private message to John$/ do
  john = Hipbot::User.find_by(name: 'John Smith')
  john.send_message("Hello, John!")
end
```

### Topics
```ruby
on /^current topic$/ do
  reply("Current topic: #{room.topic}")
end
```
```ruby
on /^change topic here$/ do
  room.set_topic("New Topic")
end
```
```ruby
on /^change topic there$/ do
  there = Hipbot::Room.find_by(name: 'there')
  there.set_topic("New Topic")
end
```

### Regexp matchdata
```ruby
on /^My name is (.*)$/ do |user_name|
  reply("Hello, #{user_name}!")
end
```
```ruby
on /^My name is (\S*) (\S*)$/ do |first_name, last_name|
  reply("Hello, #{first_name} #{last_name}!")
end
```

### Multiple regexps
```ruby
on /^My name is (.*)$/, /^I am (.*)$/ do |user_name|
  reply("Hello, #{user_name}!")
end
```

### Sender restriction
Use `:from` option to match messages only from certain users or user groups defined in configuration.
It accepts string, symbol and array values.
```ruby
configure do |c|
  # ...
  c.teams = { vip: ['John Edward', 'Mike Anderson'] }
end

on /^report status$/, from: ['Tom Smith', 'Jane Doe', :vip] do
  reply('All clear')
end
```

### Room restriction
Use `:room` option to match messages opny from certain HipChat rooms.
It accepts string, symbol, array and boolean values.
```ruby
configure do |c|
  # ...
  c.rooms = { project_rooms: ['Project 1', 'Project 2'] }
end

on /^hello$/, room: ['Public Room', :project_rooms] do
  reply('Hello!')
end
```
Match only private messages:
```ruby
on /^private hello$/, room: false do
  reply('Private hello!')
end
```
Match only room messages:
```ruby
on /^public hello$/, room: true do
  reply('Public hello!')
end
```

### Global reaction
By default, Hipbot reacts only to its HipChat mention.
Use `global: true` option to match all messages:

```ruby
on /^Hey I just met you$/, global: true do
  reply('and this is crazy...')
end
```

### Conditional reaction
Use `:if` option to specify certain dynamic conditions:
```ruby
on /^Is it friday\?$/, if: ->{ Time.now.friday? } do
  reply('Yes, indeed')
end
```
```ruby
admins = ['John Smith']
on /^add admin (.*)$/, if: ->(sender){ admins.include?(sender.name) } do |user_name|
  admins << user_name
end
```
```ruby
on /^choose volunteer$/, if: ->(room){ room.users.count > 3 } do
  reply("Choosing #{room.users.sample}")
end
```

### Method reaction
Use symbol instead of block to react with a instance method:
```ruby
def hello(user_name)
  reply("Hello #{user_name}!")
end

on /^My name is (.*)$/, :hello
```

### Presence reaction
Use `on_presence` in the same way as `on` to make presence reactions:
```ruby
class MyBot < Hipbot::Bot
  # ...
  on_presence do |status|
    case status
    when 'unavailable'
      reply("Bye bye, #{sender.name}!")
    when ''
      reply("Welcome, #{sender.name}!")
    end
  end
end
```

### Scopes
Use `scope` blocks to extract common options:
```ruby
configure do |c|
  # ...
  c.teams = { admins: ['John Edward', 'Mike Anderson'] }
end

scope from: :admins, room: true do
  on /^restart server$/ do
    # Restarting...
  end

  scope global: true do
    on /^deploy production$/ do
      # Deploying...
    end

    on /^check status$/ do
      # Checking...
    end
  end
end
```

### Default reactions
Default reaction can take the same options as regular one.
Hipbot fall backs to default reactions if there is no matching normal reaction.
```ruby
default do
  reply("I don't understand you!")
end
```
```ruby
default from: 'Mike Johnson' do
  reply("Not you again, Mike!")
end
```

### Descriptions
Use `desc` modifier to describe following reaction:
```ruby
desc '@hipbot restart server_name - Restarts the server'
on /^restart (.*)$/ do |server|
  if server.empty?
    reply("Usage: #{reaction.desc}")
  else
    # Restarting...
  end
end
```
You can fetch the descriptions and create help reaction, eg:
```ruby
on /^help$/ do
  reply Hipbot.reactions.map(&:desc).compact.join("\n")
end
```

### User managment
This behavior is experimental and not officially supported by HipChat. Bot must be an admin in order to perform these actions.
```ruby
on /^kick (.*)/ do |user_name|
  user = Hipbot::User.find_by(name: user_name)
  room.kick(user)
end
```
```ruby
on /^invite (.*)$/ do |user_name|
  user = Hipbot::User.find_by(name: user_name)
  room.invite(user)
end
```

### HTTP helpers
Use `get`, `post`, `put` and `delete` helpers to preform a HTTP requests:
```ruby
on /^curl (\S+)$/ do |url|
  get(url) do |response|
    reply(response.code)
    reply(response.headers)
    reply(response.body)
  end
end
```
```ruby
on /^ping site/ do
  get('http://example.com', ping: '1') # GET http://example.com?ping=1
end
```

### Custom response helpers
You can define your own helpers and use them inside responses like this:
```ruby
module MyHipbotHelpers
  def project_name
    "#{room.name}-project"
  end
end

class Bot < Hipbot::Bot
  configure do |c|
    # ...
    c.helpers = MyHipbotHelpers
  end

  on /^what's the project name\?$/ do
    reply(project_name)
  end
end
```

### Plugins
To define a plugin, include `Hipbot::Plugin` module in your class:
```ruby
class GreeterPlugin
  include Hipbot::Plugin

  on /^hello$/ do
    reply('Hello there!')
  end
end
```

You can access plugin data inside reaction with `plugin` helper:
```ruby
class GreeterPlugin
  include Hipbot::Plugin

  attr_accessor :language

  on /^hello$/ do
    case plugin.language
    when :en
      reply("Hello!")
    when :pl
      reply("Cześć!")
    when :jp
      reply("おはよう！")
    end
  end
end

GreeterPlugin.configure do |c|
  c.language = :jp
end
```
For more examples, check out [hipbot-plugins](https://github.com/netguru/hipbot-plugins).

### Exception handling
Define `on_exception` block in your Hipbot class to handle runtime exceptions:
```ruby
class MyBot < Hipbot::Bot
  on_exception do |e|
    hipbot_room = Hipbot::Room.find_by(name: 'hipbot room')
    reply(e.message, hipbot_room)
    # If exception was raised in reaction, there are some context variables available:
    reply("#{e.message} raised by #{message.body} from #{sender} in #{room}", hipbot_room)
  end
end
```

### Preloader for EventMachine
In order to use EventMachine runtime methods, define them within `on_preload` block in your Hipbot class:
```ruby
class MyBot < Hipbot::Bot
  on_preload do
    EM::add_periodic_timer(60) do
      Updater::update_stock_prices
      Updater::update_server_statuses
    end
  end
end
```

### Storage
Hipbot uses in-memory hash storage by default, however you can use persistent
storage adapter to speed up boot time and extend the functionality.

#### MongoDB
In order to use MongoDB storage, enable Mongoid adapter and add `allow_dynamic_fields: true` to your Mongoid config:
```ruby
require 'hipbot/storages/mongoid'
configure do |c|
  # ...
  c.storage = Hipbot::Storages::Mongoid
end
```
Sample config file:
```yaml
sessions:
  default:
    hosts:
      - localhost:27017
    database: hipbot
options:
  allow_dynamic_fields: true
```
You can optionally override user and room classes with these base models:
```ruby
module Hipbot
  class User
    include Mongoid::Document

    has_and_belongs_to_many :rooms, class_name: 'Hipbot::User', inverse_of: :users

    field :email,      type: String
    field :mention,    type: String
    field :phone,      type: String
    field :photo,      type: String
    field :title,      type: String
    field :is_online,  type: Boolean
  end
end
```
```ruby
module Hipbot
  class Room
    include Mongoid::Document

    has_and_belongs_to_many :users, class_name: 'Hipbot::User', inverse_of: :rooms

    field :archived,   type: Boolean
    field :guest_url,  type: String
    field :hipchat_id, type: String
    field :privacy,    type: String
    field :topic,      type: String
  end
end
```
#### Other storage
Storage adapter is included in room and user classes upon loading.
Make sure your adapter implements all methods from [Hipbot::Storages::Base](https://github.com/pewniak747/hipbot/blob/master/lib/hipbot/storages/base.rb)
```ruby
module MyStorageAdapter
  include Hipbot::Storages::Base
  # ...
end

configure do |c|
  # ...
  c.storage = MyStorageAdapter
end
```

## Contributing
### To do:

* add tests for Match class
* add testing adapter for testing custom responses with RSpec
* add HipChat API integration (?)

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

Read [the story behind creating HipBot](https://netguru.co/blog/posts/hipbot).
