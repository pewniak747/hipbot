require 'spec_helper'

require_relative '../../lib/hipbot/reaction'
require_relative '../../lib/hipbot/reaction_factory'

describe Hipbot::ReactionFactory do
  subject { described_class.new(stub) }

  let(:restrictions) { [] }
  let(:block) { stub }

  let(:reaction) { subject.build(restrictions, block) }

  describe "taking a regexp" do
    let(:restrictions) { [/.*/] }

    it "builds a reaction with regexp" do
      expect(reaction.regexps).to eq([/.*/])
    end

    describe "with additional options" do
      let(:restrictions) { [/.*/, { from: 'wat' }] }

      it "builds a reaction with proper options" do
        expect(reaction.options).to eq(from: 'wat', regexps: [/.*/], desc: nil)
      end
    end
  end

  describe "taking multiple regexps and options" do
    let(:restrictions) { [/.*/, /wat/, { from: 'wat' }] }

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
      subject.build(restrictions, block)
      expect(reaction.desc).to be_nil
    end
  end

  it "applies optional scope restrictions as default" do
    expect(subject.build(restrictions, block, { from: 'dave' }).options[:from]).to eq('dave')
  end
end
