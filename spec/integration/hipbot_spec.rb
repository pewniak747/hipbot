require 'spec_helper'

module HipbotHelpers
  def project_name
    "Project: #{room.name}"
  end

  def sender_first_name
    "you are #{message.sender.split[0]}"
  end
end

class AwesomePlugin
  extend Hipbot::Plugin

  on /respond awesome/ do
    reply('awesome responded')
  end
end

class CoolPlugin
  extend Hipbot::Plugin

  on /respond cool/ do
    reply('cool responded')
  end
end

class MyHipbot < Hipbot::Bot
  configure do |config|
    config.jid     = 'robbot@chat.hipchat.com'
    config.helpers = HipbotHelpers
    config.teams   = { vip: ['John Doe', 'Jane Doe'] }
    config.rooms   = { project_rooms: ['Project 1', 'Project 2'] }
  end

  default from: 'Other Guy' do
    reply('What do you mean, Other Guy?')
  end

  default do
    reply("I didn't understand you")
  end

  on /^hello hipbot!$/ do
    reply('hello!')
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

  scope from: 'John Doe' do
    on /John Doe thing/ do
      reply('doing John Doe thing')
    end

    scope room: 'Project 1' do
      on /John Doe project thing/ do
        reply('doing John Doe project thing')
      end
    end
  end

  on /deploy/, room: :project_rooms do
    reply('deploying')
  end

  on /restart/, from: :vip do
    reply('restarting')
  end

  on /room thing/, room: true do
    reply('doing room thing')
  end

  on /private thing/, room: false do
    reply('doing private thing')
  end

end

describe MyHipbot do
  before(:all) { MyHipbot.instance.setup }
  subject { MyHipbot.instance }

  let(:room)   { Hipbot::Room.create(id: '1', name: 'Project 1', topic: 'project 1 stuff only') }
  let(:sender) { Hipbot::User.create(id: '1', name: 'John Doe') }
  let(:other_room)   { Hipbot::Room.create(id: '2', name: 'Hyde Park', topic: 'nice weather today') }
  let(:other_sender) { Hipbot::User.create(id: '2', name: 'Other Guy') }

  before do
    Hipbot.bot.configuration.user = Hipbot::User.create(name: 'robbot')
  end

  describe 'configuration' do
    it 'should set robot name' do
      subject.name.should == 'robbot'
    end

    it 'should set hipchat token' do
      subject.jid.should == 'robbot@chat.hipchat.com'
    end
  end

  describe 'replying' do
    it 'should reply to hello' do
      subject.expects(:send_to_room).with(room, 'hello!')
      subject.react(sender, room, '@robbot hello hipbot!')
    end

    it 'should reply with argument' do
      subject.expects(:send_to_room).with(room, "I know I'm cool")
      subject.react(sender, room, '@robbot you\'re cool, robot')
    end

    it 'should reply to global message' do
      subject.expects(:send_to_room).with(room, 'hello!')
      subject.react(sender, room, 'hi everyone!')
    end

    it 'should respond with default reply' do
      subject.expects(:send_to_room).with(room, "I didn't understand you")
      subject.react(sender, room, '@robbot blahlblah')
    end
  end

  describe '"from" option' do
    it 'reacts to sender from required team' do
      subject.expects(:send_to_room).with(room, 'restarting')
      subject.react(sender, room, '@robbot restart')
    end

    it 'ignores sender when not in team' do
      subject.expects(:send_to_room).with(room, 'What do you mean, Other Guy?')
      subject.react(other_sender, room, '@robbot restart')
    end
  end

  describe '"room" option' do
    it 'reacts in required room' do
      subject.expects(:send_to_room).with(room, 'deploying')
      subject.react(sender, room, '@robbot deploy')
    end

    it 'ignores other rooms' do
      subject.expects(:send_to_room).with(other_room, "I didn't understand you")
      subject.react(sender, other_room, '@robbot deploy')
    end
  end

  describe 'room=true' do
    it 'reacts in any room' do
      subject.expects(:send_to_room).with(room, 'doing room thing')
      subject.react(sender, room, '@robbot room thing')
    end

    it 'ignores room commands if not in room' do
      subject.expects(:send_to_user).with(sender, "I didn't understand you")
      subject.react(sender, nil, 'room thing')
    end
  end

  describe 'room=false' do
    it 'ignores private command in room' do
      subject.expects(:send_to_room).with(room, "I didn't understand you")
      subject.react(sender, room, '@robbot private thing')
    end

    it 'allows private command if not in room' do
      subject.expects(:send_to_user).with(sender, 'doing private thing')
      subject.react(sender, nil, 'private thing')
    end
  end

  describe 'scope' do
    it 'sets its attributes to every reaction inside' do
      subject.expects(:send_to_room).with(room, 'doing John Doe thing')
      subject.react(sender, room, '@robbot John Doe thing')
    end

    it 'does not match other senders' do
      subject.expects(:send_to_room).with(room, 'What do you mean, Other Guy?')
      subject.react(other_sender, room, '@robbot John Doe thing')
    end

    it 'merges params if embedded' do
      subject.expects(:send_to_room).with(room, 'doing John Doe project thing')
      subject.react(sender, room, '@robbot John Doe project thing')
    end

    it 'ignores message from same sander in other room' do
      subject.expects(:send_to_room).with(other_room, "I didn't understand you")
      subject.react(sender, other_room, '@robbot John Doe project thing')
    end

    it 'ignores message from other sender in same room' do
      subject.expects(:send_to_room).with(room, 'What do you mean, Other Guy?')
      subject.react(other_sender, room, '@robbot John Doe project thing')
    end
  end

  describe 'custom helpers' do
    it 'should have access to room variable' do
      subject.expects(:send_to_room).with(room, 'Project: Project 1')
      subject.react(sender, room, '@robbot tell me the project name')
    end

    it 'should have access to message variable' do
      subject.expects(:send_to_room).with(room, 'you are John')
      subject.react(sender, room, '@robbot tell me my name')
    end
  end

  describe 'plugins' do
    it 'should reply to reaction defined in plugin' do
      subject.expects(:send_to_room).with(room, 'awesome responded')
      subject.react(sender, room, '@robbot respond awesome')
    end

    it 'should reply to reaction defined in second plugin' do
      subject.expects(:send_to_room).with(room, 'cool responded')
      subject.react(sender, room, '@robbot respond cool')
    end
  end
end
