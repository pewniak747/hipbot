require 'spec_helper'

describe Hipbot::Bot do
  context "#on" do
    it "should reply to no arguments" do
      subject.on /^hello there$/ do
        reply('hi!')
      end
      subject.expects(:reply).with('hi!')
      subject.tell('@robot hello there')
    end

    it "should reply with one argument" do
      subject.on /^you are (.*), robot$/ do |adj|
        reply("i know i'm #{adj}!")
      end
      subject.expects(:reply).with("i know i'm cool!")
      subject.tell('@robot you are cool, robot')
    end

    it "should reply with multipla arguments" do
      subject.on /^send "(.*)" to (.*@.*)$/ do |message, recipient|
        reply("sent \"#{message}\" to #{recipient}")
      end
      subject.expects(:reply).with('sent "hello!" to robot@robots.org')
      subject.tell('@robot send "hello!" to robot@robots.org')
    end

    it "should say when does not understand" do
      subject.on /^hello there$/ do
        reply('hi!')
      end
      subject.expects(:reply).with('I don\'t understand "hello robot!"')
      subject.tell('@robot hello robot!')
    end

    it "should say when multiple options match" do
      subject.on /hello there/ do; end
      subject.on /hello (.*)/ do; end
      subject.expects(:reply).with('I\'m not sure what to do...')
      subject.tell('@robot hello there')
    end

    it "should reply if callback is global" do
      subject.on /^you are (.*)$/, global: true do |adj|
        reply("i know i'm #{adj}!")
      end
      subject.expects(:reply).with("i know i'm cool!")
      subject.tell('you are cool')
    end

    it "should not reply if callback not global" do
      subject.on /^you are (.*)$/ do |adj|
        reply("i know i'm #{adj}!")
      end
      subject.expects(:reply).never
      subject.tell('you are cool')
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
