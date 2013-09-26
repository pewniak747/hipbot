require 'spec_helper'
require_relative '../../lib/hipbot/match.rb'

describe Hipbot::Match do
  subject { described_class.new(reaction, message) }

  let(:message) { stub(for?: true, body: 'test message') }
  let(:reaction) do
    stub(
      global?: false,
      from_anywhere?: true,
      to_anything?: false,
      from_all?: true,
      regexps: [/.*/],
      condition: proc { true }
    )
  end

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

  describe "#invoke" do
    let(:response) { stub }

    before do
      Hipbot::Response.stubs(new: response)
    end

    after do
      subject.invoke
    end

    describe "a reaction with no regexps" do
      before do
        reaction.stubs(to_anything?: true)
      end

      it "calls response with message body" do
        response.expects(:invoke).with([message.body])
      end
    end

    describe "a reaction with regexp with no variables" do
      before do
        reaction.stubs(regexps: [/.*/])
      end

      it "calls response with message body" do
        response.expects(:invoke).with([])
      end
    end

    describe "a reaction with regexp with one variable" do
      before do
        message.stubs(body: 'I like trains.')
        reaction.stubs(regexps: [/\Ai like (\w+)/i])
      end

      it "calls response with variable parsed out of message body" do
        response.expects(:invoke).with(['trains'])
      end
    end

    describe "a reaction with regexp with multiple variables" do
      before do
        message.stubs(body: 'I like trains and cars.')
        reaction.stubs(regexps: [/\Ai like (\w+) and (\w+)/i])
      end

      it "calls response with variables parsed out of message body" do
        response.expects(:invoke).with(%w{trains cars})
      end
    end

    describe "a reaction with multiple regexps with variables" do
      before do
        message.stubs(body: 'I enjoy trains and cars.')
        reaction.stubs(regexps: [/\AI enjoy (\w+) and (\w+)/, /\Ai like (\w+) and (\w+)/i])
      end

      it "calls response with variable parsed out of message body" do
        response.expects(:invoke).with(%w{trains cars})
      end
    end
  end
end
