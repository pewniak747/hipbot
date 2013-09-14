require 'spec_helper'
require_relative '../../lib/hipbot/match.rb'

describe Hipbot::Match do
  subject { described_class.new(reaction, message) }

  let(:message) { stub(for?: true, body: 'test message') }
  let(:reaction) { stub(global?: false, anywhere?: true, anything?: false, from_all?: true, regexps: [/.*/], condition: proc { true }) }

  before do
    Hipbot.stubs(:user)
  end

  describe "#matches?" do
    its(:matches?) { should be_true }

    describe "specific regexp" do
      describe "matching the message body" do
        before do
          message.stubs(body: 'test message')
          reaction.stubs(regexps: [/\Atest/])
        end

        its(:matches?) { should be_true }
      end

      describe "not matching message body" do
        before do
          message.stubs(body: 'test message')
          reaction.stubs(regexps: [/\Arandom/])
        end

        its(:matches?) { should be_false }
      end
    end

    describe "multiple regexps" do
      describe "matching message body" do
        before do
          message.stubs(body: 'test message')
          reaction.stubs(regexps: [/\Awat/, /\Atest/])
        end

        its(:matches?) { should be_true }
      end

      describe "not matching message body" do
        before do
          message.stubs(body: 'test message')
          reaction.stubs(regexps: [/\Awat/, /\Arandom/])
        end

        its(:matches?) { should be_false }
      end
    end

    describe "specific condition" do
      describe "returning true" do
        before do
          reaction.stubs(condition: proc { true })
        end

        its(:matches?) { should be_true }
      end

      describe "returning false" do
        before do
          reaction.stubs(condition: proc { false })
        end

        its(:matches?) { should be_false }
      end
    end
  end
end
