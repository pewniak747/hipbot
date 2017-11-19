require 'spec_helper'

describe "a class that inherits", Hipbot::Bot do
  let(:described_class) { Class.new(Hipbot::Bot) }

  before(:each) do
    described_class.instance.plugins.clear
    described_class.instance.setup
  end
  subject { described_class.instance }

  let(:room) { Hipbot::Room.new(name: 'Test Room') }

  context "#on" do
    let(:sender) { Hipbot::User.new(name: 'Tom Smith') }

    it "should reply to no arguments" do
      described_class.on /^hello there$/ do
        reply('hi!')
      end
      subject.should_receive(:send_to_room).with(room, 'hi!')
      subject.react(sender, room, '@robot hello there')
    end

    it "should reply with one argument" do
      described_class.on /^you are (.*), robot$/ do |adj|
        reply("i know i'm #{adj}!")
      end
      subject.should_receive(:send_to_room).with(room, "i know i'm cool!")
      subject.react(sender, room, '@robot you are cool, robot')
    end

    it "should reply with multiple arguments" do
      described_class.on /^send "(.*)" to (.*@.*)$/ do |message, recipient|
        reply("sent \"#{message}\" to #{recipient}")
      end
      subject.should_receive(:send_to_room).with(room, 'sent "hello!" to robot@robots.org')
      subject.react(sender, room, '@robot send "hello!" to robot@robots.org')
    end

    it "should say when does not understand" do
      described_class.default do |message|
        reply("I don't understand \"#{message}\"")
      end
      subject.should_receive(:send_to_room).with(room, 'I don\'t understand "hello robot!"')
      subject.react(sender, room, '@robot hello robot!')
    end

    it "should choose all matching options" do
      described_class.on /hello there/ do reply('hello there') end
      described_class.on /hello (.*)/ do reply('hello') end
      subject.should_receive(:send_to_room).with(room, 'hello there')
      subject.should_receive(:send_to_room).with(room, 'hello')
      subject.react(sender, room, '@robot hello there')
    end

    context "multiple regexps" do
      before do
        described_class.on /hello (.*)/, /good morning (.*)/, /guten tag (.*)/ do |name|
          reply("hello #{name}")
        end
      end

      it "should understand simple english" do |msg|
        subject.should_receive(:send_to_room).with(room, 'hello tom')
        subject.react(sender, room, '@robot hello tom')
      end

      it "should understand english" do |msg|
        subject.should_receive(:send_to_room).with(room, 'hello tom')
        subject.react(sender, room, '@robot good morning tom')
      end

      it "should understand german" do |msg|
        subject.should_receive(:send_to_room).with(room, 'hello tom')
        subject.react(sender, room, '@robot guten tag tom')
      end
    end

    context "global messages" do
      it "should reply if callback is global" do
        described_class.on /^you are (.*)$/, global: true do |adj|
          reply("i know i'm #{adj}!")
        end
        subject.should_receive(:send_to_room).with(room, "i know i'm cool!")
        subject.react(sender, room, 'you are cool')
      end

      it "should not reply if callback not global" do
        described_class.on /^you are (.*)$/ do |adj|
          reply("i know i'm #{adj}!")
        end
        subject.should_receive(:send_to_room).never
        subject.react(sender, room, 'you are cool')
      end
    end

    context "messages from particular sender" do
      let(:other_user) { Hipbot::User.new(name: "John") }

      it "should reply" do
        described_class.on /wazzup\?/, from: sender.name do
          reply('Wazzup, Tom?')
        end
        subject.should_receive(:send_to_room).with(room, 'Wazzup, Tom?')
        subject.react(sender, room, '@robot wazzup?')
      end

      it "should reply if sender acceptable" do
        described_class.on /wazzup\?/, from: ['someone', sender.name] do
          reply('wazzup, tom?')
        end
        subject.should_receive(:send_to_room).with(room, 'wazzup, tom?')
        subject.react(sender, room, '@robot wazzup?')
      end

      it "should not reply if sender unacceptable" do
        described_class.on /wazzup\?/, from: sender.name do
          reply('wazzup, tom?')
        end
        subject.should_receive(:send_to_room).never
        subject.react(other_user, room, '@robot wazzup?')
      end

      it "should not reply if sender does not match" do
        described_class.on /wazzup\?/, from: [sender.name] do
          reply('wazzup, tom?')
        end
        subject.should_receive(:send_to_room).never
        subject.react(other_user, room, '@robot wazzup?')
      end
    end

    context "messages in particular room" do
      let(:other_room) { Hipbot::Room.new(name: 'Test Room 2') }

      it "should reply" do
        described_class.on /wazzup\?/, room: 'Test Room' do
          reply('Wazzup, Tom?')
        end
        subject.should_receive(:send_to_room).with(room, 'Wazzup, Tom?')
        subject.react(sender, room, '@robot wazzup?')
      end

      it "should reply if room acceptable" do
        described_class.on /wazzup\?/, room: ['Test Room 2', 'Test Room'] do
          reply('wazzup, tom?')
        end
        subject.should_receive(:send_to_room).with(room, 'wazzup, tom?')
        subject.react(sender, room, '@robot wazzup?')
      end

      it "should not reply if room unacceptable" do
        described_class.on /wazzup\?/, room: 'Test Room' do
          reply('wazzup, tom?')
        end
        subject.should_receive(:send_to_room).never
        subject.react(sender, other_room, '@robot wazzup?')
      end

      it "should not reply if room does not match" do
        described_class.on /wazzup\?/, room: ['Test Room 2'] do
          reply('wazzup, tom?')
        end
        subject.should_receive(:send_to_room).never
        subject.react(sender, room, '@robot wazzup?')
      end
    end

    context "response helper" do
      let(:user){ Hipbot::User.new(name: 'Tom Smith') }

      it "message" do
        described_class.on /.*/ do
          reply("you said: #{message.body}")
        end
        subject.should_receive(:send_to_room).with(room, "you said: hello")
        subject.react(user, room, "@robot hello")
      end

      it "sender" do
        described_class.on /.*/ do
          reply("you are: #{sender.name}")
        end
        subject.should_receive(:send_to_room).with(room, "you are: Tom Smith")
        subject.react(user, room, "@robot hello")
      end

      it "recipients" do
        described_class.on /.*/ do
          reply("recipients: #{message.recipients.join(', ')}")
        end
        subject.should_receive(:send_to_room).with(room, "recipients: robot, dave")
        subject.react(user, room, "@robot tell @dave hello from me")
      end

      it "sender name" do
        described_class.on /.*/ do
          reply(message.sender.first_name)
        end
        subject.should_receive(:send_to_room).with(room, 'Tom')
        subject.react(user, room, '@robot What\'s my name?')
      end

      it "mentions" do
        described_class.on /.*/ do
          reply(message.mentions.join(' '))
        end
        subject.should_receive(:send_to_room).with(room, 'dave rachel')
        subject.react(user, room, '@robot do you know @dave? @dave is @rachel father')
      end
    end

    context "plugins" do
      let!(:plugin) {
        Class.new do
          include Hipbot::Plugin

          on /plugin respond/ do
            reply("plugin ack")
          end

          on /plugin method/ do
            reply(plugin.some_method)
          end

          default do
            reply("plugin default")
          end

          def some_method
            "some method"
          end
        end
      }

      it "should respond to reaction defined in plugin" do
        subject.should_receive(:send_to_room).with(room, 'plugin ack')
        subject.react(sender, room, '@robot plugin respond')
      end

      it "should respond to default reaction defined in plugin" do
        subject.should_receive(:send_to_room).with(room, 'plugin default')
        subject.react(sender, room, '@robot blahblah')
      end

      it "shouldn't respond to default defined in bot if plugins define own defaults" do
        described_class.default do
          reply('bot default')
        end
        subject.should_receive(:send_to_room).with(room, 'plugin default')
        subject.react(sender, room, '@robot blahblah')
      end

      it 'should have access to #plugin inside reaction' do
        subject.should_receive(:send_to_room).with(room, 'some method')
        subject.react(sender, room, '@robot plugin method')
      end
    end
  end

  describe "configurable options" do
    Hipbot::Configuration::OPTIONS.each do |option|
      it "should delegate #{option} to configuration" do
        value = double
        subject.configuration.should_receive(option).and_return(value)
        subject.send(option)
      end
    end
  end
end
