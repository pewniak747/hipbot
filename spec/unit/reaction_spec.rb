require 'spec_helper'

describe Hipbot::Reaction do
  subject { Hipbot::Reaction }

  context 'instance' do
    let(:options){ {} }
    let(:reaction){ subject.new(@plugin, options, @block) }

    it '#in_any_room?' do
      reaction.in_any_room?.should be_false
      options[:room] = true
      reaction.in_any_room?.should be_true
    end

    it '#to_anything?' do
      reaction.to_anything?.should be_true
      reaction.options[:regexps] = nil
      reaction.to_anything?.should be_true
    end

    it '#from_anywhere?' do
      reaction.from_anywhere?.should be_true
      reaction.options[:room] = nil
      reaction.from_anywhere?.should be_true
    end

    it '#condition' do
      reaction.condition.call.should be_true
      reaction.options[:if] = proc{ false }
      reaction.condition.call.should be_false
    end

    it '#delete' do
      @plugin = double(reactions: [reaction])
      reaction.plugin = @plugin
      reaction.delete
      @plugin.reactions.should be_empty
    end

    it '#desc' do
      reaction.desc.should be_nil
      reaction.options[:desc] = 'description'
      reaction.desc.should == 'description'
    end

    it '#from_all?' do
      reaction.from_all?.should be_true
      reaction.options[:room] = nil
      reaction.from_all?.should be_true
    end

    it '#global?' do
      reaction.global?.should be_false
      reaction.options = { global: true }
      reaction.global?.should be_true
    end

    it '#plugin_name' do
      @plugin = (MyPlugins = Class.new)
      reaction.plugin_name.should == 'MyPlugins'
    end

    it '#match_with' do
      message = double
      reaction.match_with(message).should == Hipbot::Match.new(reaction, message)
    end

    it '#to_private_message?' do
      reaction.to_private_message?.should be_false
      reaction.options[:room] = false
      reaction.to_private_message?.should be_true
    end

    it '#regexps' do
      options[:regexps] = [/^sample regexp$/i, /^another one$/]
      reaction.regexps.should == [/^sample regexp$/i, /^another one$/i]
    end

    it '#readable_command' do
      options[:regexps] = [/^sample regexp$/i, /^another one$/]
      reaction.readable_command.should == 'sample regexp or another one'
    end

    it '#rooms' do
      rooms = ['Room 1', 'Room 2']
      Hipbot.bot = double(rooms: { special_rooms: rooms })
      options[:room] = [:special_rooms, 'Room 3']
      reaction.rooms.should == [*rooms, 'Room 3']
    end

    it '#users' do
      users = ['User 1', 'User 2']
      Hipbot.bot = double(teams: { special_users: users })
      options[:from] = [:special_users, 'User 3']
      reaction.users.should == [*users, 'User 3']
    end
  end
end
