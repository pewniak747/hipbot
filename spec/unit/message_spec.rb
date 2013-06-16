require 'spec_helper'

describe Hipbot::Message do
  subject { Hipbot::Message }
  let(:sender) { stub }
  let(:room) { stub }

  it "should have a body" do
    message = subject.new('this is a message', room, sender)
    message.body.should == 'this is a message'
  end

  it "should have a sender" do
    message = subject.new('this is a message', room, sender)
    message.sender.should == sender
  end

  it "should have no recipients" do
    message = subject.new('this is a message', room, sender)
    message.recipients.should be_empty
  end

  it "should have one recipient" do
    message = subject.new('this is a message for @tom', room, sender)
    message.recipients.should include('tom')
  end

  it "should have two recipients" do
    message = subject.new('@dave, this is a message for @tom', room, sender)
    message.recipients.should include('tom')
    message.recipients.should include('dave')
  end

  it "should strip primary recipient from message" do
    message = subject.new('@dave this is a message for @tom', room, sender)
    message.body.should == 'this is a message for @tom'
  end

  it "should strip primary recipient from message with commma" do
    message = subject.new('@dave, this is a message for @tom', room, sender)
    message.body.should == 'this is a message for @tom'
  end

  it "should be for bot" do
    user = stub(:mention => 'robot')
    message = subject.new('hello @robot!', room, sender)
    message.for?(user).should be_true
  end

  it "should not be for bot" do
    user = stub(:mention => 'robot')
    message = subject.new('hello @tom!', room, sender)
    message.for?(user).should be_false
  end
end
