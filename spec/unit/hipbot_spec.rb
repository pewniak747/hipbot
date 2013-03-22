require 'spec_helper'

describe "a class that inherits", Hipbot::Bot do
  let(:described_class) { Class.new(Hipbot::Bot) }
  subject { described_class.new }

  context "#on" do
    let(:sender) { stub_everything(name: 'Tom Smith') }
    let(:room)   { stub_everything }

    it "should reply to no arguments" do
      subject.on /^hello there$/ do
        reply('hi!')
      end
      subject.expects(:send_to_room).with(room, 'hi!')
      subject.react(sender, room, '@robot hello there')
    end

    it "should reply with one argument" do
      subject.on /^you are (.*), robot$/ do |adj|
        reply("i know i'm #{adj}!")
      end
      subject.expects(:send_to_room).with(room, "i know i'm cool!")
      subject.react(sender, room, '@robot you are cool, robot')
    end

    it "should reply with multiple arguments" do
      subject.on /^send "(.*)" to (.*@.*)$/ do |message, recipient|
        reply("sent \"#{message}\" to #{recipient}")
      end
      subject.expects(:send_to_room).with(room, 'sent "hello!" to robot@robots.org')
      subject.react(sender, room, '@robot send "hello!" to robot@robots.org')
    end

    it "should say when does not understand" do
      described_class.default do |message|
        reply("I don't understand \"#{message}\"")
      end
      subject.expects(:send_to_room).with(room, 'I don\'t understand "hello robot!"')
      subject.react(sender, room, '@robot hello robot!')
    end

    it "should choose first option when multiple options match" do
      subject.on /hello there/ do reply('hello there') end
      subject.on /hello (.*)/ do reply('hello') end
      subject.expects(:send_to_room).with(room, 'hello there')
      subject.react(sender, room, '@robot hello there')
    end

    context "multiple regexps" do
      before do
        subject.on /hello (.*)/, /good morning (.*)/, /guten tag (.*)/ do |name|
          reply("hello #{name}")
        end
      end

      it "should understand simple english" do |msg|
        subject.expects(:send_to_room).with(room, 'hello tom')
        subject.react(sender, room, '@robot hello tom')
      end

      it "should understand english" do |msg|
        subject.expects(:send_to_room).with(room, 'hello tom')
        subject.react(sender, room, '@robot good morning tom')
      end

      it "should understand german" do |msg|
        subject.expects(:send_to_room).with(room, 'hello tom')
        subject.react(sender, room, '@robot guten tag tom')
      end
    end

    context "global messages" do
      it "should reply if callback is global" do
        subject.on /^you are (.*)$/, global: true do |adj|
          reply("i know i'm #{adj}!")
        end
        subject.expects(:send_to_room).with(room, "i know i'm cool!")
        subject.react(sender, room, 'you are cool')
      end

      it "should not reply if callback not global" do
        subject.on /^you are (.*)$/ do |adj|
          reply("i know i'm #{adj}!")
        end
        subject.expects(:send_to_room).never
        subject.react(sender, room, 'you are cool')
      end
    end

    context "messages from particular sender" do
      let(:other_user) { stub(name: "John") }
      it "should reply" do
        subject.on /wazzup\?/, from: sender.name do
          reply('Wazzup, Tom?')
        end
        subject.expects(:send_to_room).with(room, 'Wazzup, Tom?')
        subject.react(sender, room, '@robot wazzup?')
      end
      it "should reply if sender acceptable" do
        subject.on /wazzup\?/, from: [stub, sender.name] do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).with(room, 'wazzup, tom?')
        subject.react(sender, room, '@robot wazzup?')
      end
      it "should not reply if sender unacceptable" do
        subject.on /wazzup\?/, from: sender.name do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).never
        subject.react(other_user, room, '@robot wazzup?')
      end
      it "should not reply if sender does not match" do
        subject.on /wazzup\?/, from: [sender.name] do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).never
        subject.react(other_user, room, '@robot wazzup?')
      end
    end

    context "messages in particular room" do
      let(:room)       { stub(:name => 'room') }
      let(:other_room) { stub(:name => 'other_room') }
      it "should reply" do
        subject.on /wazzup\?/, room: 'room' do
          reply('Wazzup, Tom?')
        end
        subject.expects(:send_to_room).with(room, 'Wazzup, Tom?')
        subject.react(sender, room, '@robot wazzup?')
      end
      it "should reply if room acceptable" do
        subject.on /wazzup\?/, room: ['other_room', 'room'] do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).with(room, 'wazzup, tom?')
        subject.react(sender, room, '@robot wazzup?')
      end
      it "should not reply if room unacceptable" do
        subject.on /wazzup\?/, room: 'room' do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).never
        subject.react(sender, other_room, '@robot wazzup?')
      end
      it "should not reply if room does not match" do
        subject.on /wazzup\?/, room: ['other_room'] do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).never
        subject.react(sender, room, '@robot wazzup?')
      end
    end

    context "response helper" do
      let(:user){ stub(name: 'Tom Smith', first_name: 'Tom') }

      it "message" do
        subject.on /.*/ do
          reply("you said: #{message.body}")
        end
        subject.expects(:send_to_room).with(room, "you said: hello")
        subject.react(user, room, "@robot hello")
      end

      it "sender" do
        subject.on /.*/ do
          reply("you are: #{sender.name}")
        end
        subject.expects(:send_to_room).with(room, "you are: Tom Smith")
        subject.react(user, room, "@robot hello")
      end

      it "recipients" do
        subject.on /.*/ do
          reply("recipients: #{message.recipients.join(', ')}")
        end
        subject.expects(:send_to_room).with(room, "recipients: robot, dave")
        subject.react(user, room, "@robot tell @dave hello from me")
      end

      it "sender name" do
        subject.on /.*/ do
          reply(message.sender.first_name)
        end
        subject.expects(:send_to_room).with(room, 'Tom')
        subject.react(user, room, '@robot What\'s my name?')
      end

      it "mentions" do
        subject.on /.*/ do
          reply(message.mentions.join(' '))
        end
        subject.expects(:send_to_room).with(room, 'dave rachel')
        subject.react(user, room, '@robot do you know @dave? @dave is @rachel father')
      end
    end
  end

  describe "configurable options" do
    Hipbot::Bot::CONFIGURABLE_OPTIONS.each do |option|
      it "should delegate #{option} to configuration" do
        value = stub
        subject.configuration.expects(option).returns(value)
        subject.send(option)
      end
    end
  end
end
