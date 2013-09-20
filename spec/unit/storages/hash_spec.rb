require 'spec_helper'

describe Hipbot::Storages::Hash do
  let(:collection) { Class.new{ include Hipbot::Storages::Hash } }
  let(:item) { collection.find(1) }
  before do
    @item = collection.create(id: 1, name: 'item', something: 'value')
  end

  context 'collection' do
    context '#create' do
      it 'creates new item' do
        collection.count.should == 1
      end

      it 'saves the id' do
        @item.id.should == 1
      end

      it 'saves the attributes' do
        @item.attributes[:something].should == 'value'
      end
    end

    context 'lookups' do
      it 'finds by id' do
        item.should == @item
      end

      it 'finds by params' do
        collection.find_by(name: 'item') == @item
        collection.find_by(name: 'item', id: 1) == @item
        collection.find_by(name: 'item', id: 1, something: 'value') == @item
      end

      it 'finds all by params' do
        @item2 = collection.create(id: 2, name: 'item 2', something: 'value')
        collection.where(something: 'value').should == [@item, @item2]
      end
    end
  end

  context 'item' do
    it 'aliases :name as :to_s' do
      item.to_s.should == item.name
    end

    context 'updating attributes on lookup result' do
      before do
        item.update_attributes(name: 'item 2', something: 'value 2')
      end

      it 'changes the attributes' do
        @item.name.should == 'item 2'
        @item.attributes[:something].should == 'value 2'
      end
    end

    context 'updating attributes on created object' do
      before do
        @item.update_attributes(name: 'item 3', something: 'value 3')
      end

      it 'changes the attributes' do
        item.name.should == 'item 3'
        item.attributes[:something].should == 'value 3'
      end
    end

    it 'destroys itself' do
      item.destroy
      collection.should be_empty
    end
  end
end
