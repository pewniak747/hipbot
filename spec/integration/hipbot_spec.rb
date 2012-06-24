require 'spec_helper'

class MyHipbot < Hipbot::Bot
  configure do |config|
    config.name = 'robbot'
    config.hipchat_token = 'my-hipchat-token'
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
end

describe MyHipbot do
  describe "configuration" do
    it "should set robot name" do
      subject.name.should == 'robbot'
    end

    it "should set hipchat token" do
      subject.hipchat_token.should == 'my-hipchat-token'
    end
  end

  describe "replying" do
    # TODO: replace with actual objects
    let(:room) { stub_everything }
    let(:sender) { stub_everything }

    it "should reply to hello" do
      subject.expects(:reply).with(room, 'hello!')
      subject.tell(sender, room, '@robbot hello hipbot!')
    end

    it "should reply with argument" do
      subject.expects(:reply).with(room, "I know I'm cool")
      subject.tell(sender, room, "@robbot you're cool, robot")
    end

    it "should reply to global message" do
      subject.expects(:reply).with(room, "hello!")
      subject.tell(sender, room, "hi everyone!")
    end
  end
end
