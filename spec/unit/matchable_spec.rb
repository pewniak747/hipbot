require 'spec_helper'

describe Hipbot::Matchable do
  include Hipbot::Matchable

  let(:sender) { Hipbot::User.new(name: 'test user') }
  let(:room) { Hipbot::Room.new(name: 'test room') }

  def plugins
    []
  end

  describe '#react' do
    it 'calls #invoke_all on Match' do
      Hipbot::Match.should_receive(:invoke_all)
      react(sender, room, 'test message')
    end
  end
end
