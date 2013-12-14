require 'spec_helper'
require_relative './my_hipbot'

describe MyHipbot do
  before(:all) { MyHipbot.instance.setup }
  subject { MyHipbot.instance }

  let(:room)   { Hipbot::Room.create(id: '1', name: 'Project 1', topic: 'project 1 stuff only') }
  let(:sender) { Hipbot::User.create(id: '1', name: 'John Doe') }
  let(:other_room)   { Hipbot::Room.create(id: '2', name: 'Hyde Park', topic: 'nice weather today') }
  let(:other_sender) { Hipbot::User.create(id: '2', name: 'Other Guy') }

  describe 'configuration' do
    it 'should set robot name' do
      subject.name.should == 'robot'
    end

    it 'should set hipchat token' do
      subject.jid.should == 'robbot@chat.hipchat.com'
    end
  end

  describe 'presence reactions' do
    it 'greets joining user', focus: true do
      subject.should_receive(:send_to_room).with(room, 'Welcome, John Doe!')
      subject.react_to_presence(sender, :available, room)
    end
  end

  describe 'replying' do
    it 'should reply to hello' do
      subject.should_receive(:send_to_room).with(room, 'hello!')
      subject.react(sender, room, '@robot hello hipbot!')
    end

    it 'should reply with argument' do
      subject.should_receive(:send_to_room).with(room, "I know I'm cool")
      subject.react(sender, room, '@robot you\'re cool, robot')
    end

    it 'should reply to global message' do
      subject.should_receive(:send_to_room).with(room, 'hello!')
      subject.react(sender, room, 'hi everyone!')
    end

    it 'should respond with default reply' do
      subject.should_receive(:send_to_room).with(room, "I didn't understand you")
      subject.react(sender, room, '@robot blahlblah')
    end
  end

  describe '"from" option' do
    it 'reacts to sender from required team' do
      subject.should_receive(:send_to_room).with(room, 'restarting')
      subject.react(sender, room, '@robot restart')
    end

    it 'ignores sender when not in team' do
      subject.should_receive(:send_to_room).with(room, 'What do you mean, Other Guy?')
      subject.react(other_sender, room, '@robot restart')
    end
  end

  describe '"room" option' do
    it 'reacts in required room' do
      subject.should_receive(:send_to_room).with(room, 'deploying')
      subject.react(sender, room, '@robot deploy')
    end

    it 'ignores other rooms' do
      subject.should_receive(:send_to_room).with(other_room, "I didn't understand you")
      subject.react(sender, other_room, '@robot deploy')
    end
  end

  describe 'room=true' do
    it 'reacts in any room' do
      subject.should_receive(:send_to_room).with(room, 'doing room thing')
      subject.react(sender, room, '@robot room thing')
    end

    it 'ignores room commands if not in room' do
      subject.should_receive(:send_to_user).with(sender, "I didn't understand you")
      subject.react(sender, nil, 'room thing')
    end
  end

  describe 'room=false' do
    it 'ignores private command in room' do
      subject.should_receive(:send_to_room).with(room, "I didn't understand you")
      subject.react(sender, room, '@robot private thing')
    end

    it 'allows private command if not in room' do
      subject.should_receive(:send_to_user).with(sender, 'doing private thing')
      subject.react(sender, nil, 'private thing')
    end
  end

  describe 'scope' do
    it 'sets its attributes to every reaction inside' do
      subject.should_receive(:send_to_room).with(room, 'doing John Doe thing')
      subject.react(sender, room, '@robot John Doe thing')
    end

    it 'does not match other senders' do
      subject.should_receive(:send_to_room).with(room, 'What do you mean, Other Guy?')
      subject.react(other_sender, room, '@robot John Doe thing')
    end

    it 'merges params if embedded' do
      subject.should_receive(:send_to_room).with(room, 'doing John Doe project thing')
      subject.react(sender, room, '@robot John Doe project thing')
    end

    it 'ignores message from same sander in other room' do
      subject.should_receive(:send_to_room).with(other_room, "I didn't understand you")
      subject.react(sender, other_room, '@robot John Doe project thing')
    end

    it 'ignores message from other sender in same room' do
      subject.should_receive(:send_to_room).with(room, 'What do you mean, Other Guy?')
      subject.react(other_sender, room, '@robot John Doe project thing')
    end
  end

  describe 'custom helpers' do
    it 'should have access to room variable' do
      subject.should_receive(:send_to_room).with(room, 'Project: Project 1')
      subject.react(sender, room, '@robot tell me the project name')
    end

    it 'should have access to message variable' do
      subject.should_receive(:send_to_room).with(room, 'you are John')
      subject.react(sender, room, '@robot tell me my name')
    end
  end

  describe 'plugins' do
    it 'should reply to reaction defined in plugin' do
      subject.should_receive(:send_to_room).with(room, 'awesome responded')
      subject.react(sender, room, '@robot respond awesome')
    end

    it 'should reply to reaction defined in second plugin' do
      subject.should_receive(:send_to_room).with(room, 'cool responded')
      subject.react(sender, room, '@robot respond cool')
    end
  end

  describe 'method reaction' do
    it 'should reply to a method reaction defined in plugin' do
      subject.should_receive(:send_to_room).with(room, 'parameter: empty')
      subject.react(sender, room, '@robot method reaction')
    end

    it 'should reply to a method reaction defined in plugin with parameters' do
      subject.should_receive(:send_to_room).with(room, 'parameter: method param')
      subject.react(sender, room, '@robot method reaction method param')
    end

    it 'should reply to a scope method reaction defined in plugin' do
      subject.should_receive(:send_to_room).with(room, 'scope method reaction')
      subject.react(sender, room, '@robot scope method reaction')
    end

    it 'should reply to a scope regexp with method reaction defined in plugin' do
      subject.should_receive(:send_to_room).with(room, 'parameter: empty')
      subject.react(sender, room, '@robot scope regexp')
    end
  end
end
