require 'spec_helper'

describe Hipbot::User do
  subject { described_class.new(id: '1234', name: 'test bot', mention: 'testbotmention') }

  its(:first_name) { should == 'test' }
  its(:mention) { should == 'testbotmention' }

  describe "when no mention is provided" do
    subject { described_class.new(id: '1234', name: 'test bot name') }
    its(:mention) { should == 'testbotname' }
  end
end
