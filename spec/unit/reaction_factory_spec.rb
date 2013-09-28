require 'spec_helper'

require_relative '../../lib/hipbot/reaction'
require_relative '../../lib/hipbot/reaction_factory'

describe Hipbot::ReactionFactory do
  subject { described_class.new(stub) }

  let(:params) { [] }
  let(:block) { stub }

  let(:options_stack) { [subject.get_reaction_options(params)] }
  let(:reaction) { subject.build(options_stack, block) }

  describe "taking a regexp" do
    let(:params) { [/.*/] }

    it "builds a reaction with regexp" do
      expect(reaction.regexps).to eq([/.*/i])
    end

    describe "with additional options" do
      let(:params) { [/.*/, { from: 'wat' }] }

      it "builds a reaction with proper options" do
        expect(reaction.options).to eq(from: 'wat', regexps: [/.*/], desc: nil)
      end
    end
  end

  describe "taking multiple regexps and options" do
    let(:params) { [/.*/, /wat/, { from: 'wat' }] }

    it "builds a reaction with proper options" do
      expect(reaction.options).to eq(from: 'wat', regexps: [/.*/, /wat/], desc: nil)
    end
  end

  describe "setting description" do
    before do
      subject.description('woot')
    end

    it "builds reaction with proper description" do
      expect(reaction.desc).to eq('woot')
    end

    it "resets description after first built reaction" do
      subject.build(params, block)
      expect(reaction.desc).to be_nil
    end
  end

  it "applies optional scope params as default" do
    expect(subject.build([{ from: 'dave' }], block).options[:from]).to eq('dave')
  end
end
