require 'spec_helper'

describe Hipbot::Match do
  subject { described_class.new(reaction, message) }

  let(:message) { double(for?: true, body: 'test message', private?: false) }
  let(:reaction) do
    double(
      global?: false,
      from_anywhere?: true,
      to_anything?: false,
      from_all?: true,
      regexps: [/.*/],
      condition: proc { true }
    )
  end

  before do
    Hipbot.stub(:user)
  end

  describe "#matches?" do
    its(:matches?) { should be_true }

    describe "specific regexp" do
      describe "matching the message body" do
        before do
          message.stub(body: 'test message')
          reaction.stub(regexps: [/\Atest/])
        end

        its(:matches?) { should be_true }
      end

      describe "not matching message body" do
        before do
          message.stub(body: 'test message')
          reaction.stub(regexps: [/\Arandom/])
        end

        its(:matches?) { should be_false }
      end
    end

    describe "multiple regexps" do
      describe "matching message body" do
        before do
          message.stub(body: 'test message')
          reaction.stub(regexps: [/\Awat/, /\Atest/])
        end

        its(:matches?) { should be_true }
      end

      describe "not matching message body" do
        before do
          message.stub(body: 'test message')
          reaction.stub(regexps: [/\Awat/, /\Arandom/])
        end

        its(:matches?) { should be_false }
      end
    end

    describe "specific condition" do
      describe "returning true" do
        before do
          reaction.stub(condition: proc { true })
        end

        its(:matches?) { should be_true }
      end

      describe "returning false" do
        before do
          reaction.stub(condition: proc { false })
        end

        its(:matches?) { should be_false }
      end
    end
  end

  describe "#invoke" do
    let(:response) { double }

    before do
      Hipbot::Response.stub(new: response)
    end

    after do
      subject.invoke
    end

    describe "a reaction with no regexps" do
      before do
        reaction.stub(to_anything?: true)
      end

      it "calls response with message body" do
        response.should_receive(:invoke).with([message.body])
      end
    end

    describe "a reaction with regexp with no variables" do
      before do
        reaction.stub(regexps: [/.*/])
      end

      it "calls response with message body" do
        response.should_receive(:invoke).with([])
      end
    end

    describe "a reaction with regexp with one variable" do
      before do
        message.stub(body: 'I like trains.')
        reaction.stub(regexps: [/\Ai like (\w+)/i])
      end

      it "calls response with variable parsed out of message body" do
        response.should_receive(:invoke).with(['trains'])
      end
    end

    describe "a reaction with regexp with multiple variables" do
      before do
        message.stub(body: 'I like trains and cars.')
        reaction.stub(regexps: [/\Ai like (\w+) and (\w+)/i])
      end

      it "calls response with variables parsed out of message body" do
        response.should_receive(:invoke).with(%w{trains cars})
      end
    end

    describe "a reaction with multiple regexps with variables" do
      before do
        message.stub(body: 'I enjoy trains and cars.')
        reaction.stub(regexps: [/\AI enjoy (\w+) and (\w+)/, /\Ai like (\w+) and (\w+)/i])
      end

      it "calls response with variable parsed out of message body" do
        response.should_receive(:invoke).with(%w{trains cars})
      end
    end
  end
end
