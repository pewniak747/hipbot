require 'spec_helper'

class MyHipbot < Hipbot::Bot
  configure do |config|
    config.name = 'robbot'
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
  end

  describe "replying" do
    it "should reply to hello" do
      subject.expects(:reply).with('hello!')
      subject.tell('@robbot hello hipbot!')
    end

    it "should reply with argument" do
      subject.expects(:reply).with("I know I'm cool")
      subject.tell("@robbot you're cool, robot")
    end

    it "should reply to global message" do
      subject.expects(:reply).with("hello!")
      subject.tell("hi everyone!")
    end
  end
end
