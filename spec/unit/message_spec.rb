require 'spec_helper'

describe Hipbot::Message do
  subject { Hipbot::Message }
  let(:sender) { stub }

  it "should have a body" do
    message = subject.new('this is a message', sender)
    message.body.should == 'this is a message'
  end

  it "should have a sender" do
    message = subject.new('this is a message', sender)
    message.sender.should == sender
  end

  it "should have no recipients" do
    message = subject.new('this is a message', sender)
    message.recipients.should be_empty
  end

  it "should have one recipient" do
    message = subject.new('this is a message for @tom', sender)
    message.recipients.should include('tom')
  end

  it "should have one long recipient" do
    message = subject.new('message for @"tom jones", deal with it', sender)
    message.recipients.should include('tom jones')
  end

  it "should have two recipients" do
    message = subject.new('@dave, this is a message for @tom', sender)
    message.recipients.should include('tom')
    message.recipients.should include('dave')
  end

  it "should strip primary recipient from message" do
    message = subject.new('@dave this is a message for @tom', sender)
    message.body.should == 'this is a message for @tom'
  end

  it "should strip primary recipient from message with commma" do
    message = subject.new('@dave, this is a message for @tom', sender)
    message.body.should == 'this is a message for @tom'
  end

  it "should be for bot" do
    user = stub(:mention => 'robot')
    message = subject.new('hello @robot!', sender)
    message.for?(user).should be_true
  end

  it "should not be for bot" do
    user = stub(:mention => 'robot')
    message = subject.new('hello @tom!', sender)
    message.for?(user).should be_false
  end
end
