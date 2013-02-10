require 'spec_helper'

describe Hipbot::Bot do
  context "#on" do
    let(:sender) { stub_everything }
    let(:room) { stub_everything }

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
      Hipbot::Bot.default do |message|
        reply("I don't understand \"#{message}\"")
      end
      subject.expects(:send_to_room).with(room, 'I don\'t understand "hello robot!"')
      subject.react(sender, room, '@robot hello robot!')
      Hipbot::Bot.class_variable_set :@@default_reaction, nil
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
      it "should reply" do
        subject.on /wazzup\?/, from: sender do
          reply('Wazzup, Tom?')
        end
        subject.expects(:send_to_room).with(room, 'Wazzup, Tom?')
        subject.react(sender, room, '@robot wazzup?')
      end
      it "should reply if sender acceptable" do
        subject.on /wazzup\?/, from: [stub, sender] do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).with(room, 'wazzup, tom?')
        subject.react(sender, room, '@robot wazzup?')
      end
      it "should not reply if sender unacceptable" do
        subject.on /wazzup\?/, from: sender do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).never
        subject.react(stub, room, '@robot wazzup?')
      end
      it "should not reply if sender does not match" do
        subject.on /wazzup\?/, from: [sender] do
          reply('wazzup, tom?')
        end
        subject.expects(:send_to_room).never
        subject.react(stub, room, '@robot wazzup?')
      end
    end

    context "messages in particular room" do
      let(:room) { stub(:name => 'room') }
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
      it "message" do
        subject.on /.*/ do
          reply("you said: #{message.body}")
        end
        subject.expects(:send_to_room).with(room, "you said: hello")
        subject.react(stub, room, "@robot hello")
      end

      it "sender" do
        subject.on /.*/ do
          reply("you are: #{sender}")
        end
        subject.expects(:send_to_room).with(room, "you are: tom")
        subject.react('tom', room, "@robot hello")
      end

      it "recipients" do
        subject.on /.*/ do
          reply("recipients: #{message.recipients.join(', ')}")
        end
        subject.expects(:send_to_room).with(room, "recipients: robot, dave")
        subject.react('tom', room, "@robot tell @dave hello from me")
      end

      it "sender name" do
        subject.on /.*/ do
          reply(message.sender_name)
        end
        subject.expects(:send_to_room).with(room, 'Tom')
        subject.react('Tom Smith', room, '@robot What\'s my name?')
      end

      it "mentions" do
        subject.on /.*/ do
          reply(message.mentions.join(' '))
        end
        subject.expects(:send_to_room).with(room, 'dave rachel')
        subject.react('Tom Smith', room, '@robot do you know @dave? @dave is @rachel father')
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
