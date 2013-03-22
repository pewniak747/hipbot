require 'spec_helper'

module HipbotHelpers
  def project_name
    "#{room.name} project"
  end

  def sender_first_name
    "you are #{message.sender.split[0]}"
  end
end

class AwesomePlugin < Hipbot::Plugin
  on /respond plugin/ do
    reply("plugin responded")
  end
end

class MyHipbot < Hipbot::Bot
  configure do |config|
    config.name = 'robbot'
    config.jid = 'robbot@chat.hipchat.com'
    config.helpers = HipbotHelpers
    config.plugins = [ AwesomePlugin ]
  end

  default do
    reply("I didn't understand you")
  end
  on /^hello hipbot!$/ do
    reply("hello!")
  end
  on /you're (.*), robot/ do |adj|
    reply("I know I'm #{adj}")
  end
  on /hi everyone!/, global: true do
    reply('hello!')
  end
  on /tell me the project name/ do
    reply(project_name)
  end
  on /tell me my name/ do
    reply("you are #{sender.first_name}")
  end
  default do
    reply("I didn't understand you")
  end
end

describe MyHipbot do
  # TODO: replace with actual objects
  let(:room)   { Hipbot::Room.create('1', 'private', topic: 'topic') }
  let(:sender) { Hipbot::User.create('1', 'John Doe') }

  describe "configuration" do
    it "should set robot name" do
      subject.name.should == 'robbot'
    end

    it "should set hipchat token" do
      subject.jid.should == 'robbot@chat.hipchat.com'
    end
  end

  describe "replying" do
    it "should reply to hello" do
      subject.expects(:send_to_room).with(room, 'hello!')
      subject.react(sender, room, '@robbot hello hipbot!')
    end

    it "should reply with argument" do
      subject.expects(:send_to_room).with(room, "I know I'm cool")
      subject.react(sender, room, "@robbot you're cool, robot")
    end

    it "should reply to global message" do
      subject.expects(:send_to_room).with(room, "hello!")
      subject.react(sender, room, "hi everyone!")
    end

    it "should respond with default reply" do
      subject.expects(:send_to_room).with(room, "I didn't understand you")
      subject.react(sender, room, "@robbot blahlblah")
    end
  end

  describe "custom helpers" do
    it "should have access to room variable" do
      subject.expects(:send_to_room).with(room, 'private project')
      subject.react(sender, room, '@robbot tell me the project name')
    end

    it "should have access to message variable" do
      subject.expects(:send_to_room).with(room, 'you are John')
      subject.react(sender, room, '@robbot tell me my name')
    end
  end

  describe "plugins" do
    it "should reply to reaction defined in plugin" do
      subject.expects(:send_to_room).with(room, 'plugin responded')
      subject.react(sender, room, '@robbot respond plugin')
    end
  end
end
