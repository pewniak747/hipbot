module Hipbot
  module Collection
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
      attr_accessor :id, :name, :attributes
      alias_method :to_s, :name
    end

    def initialize args
      self.id         = args.delete(:id)
      self.name       = args.delete(:name)
      self.attributes = args
    end

    def update_attribute key, value
      if key == name
        self.name = value
      else
        self.attributes[key] = value
      end
    end

    def update_attributes hash
      hash.each do |k, v|
        update_attribute k, v
      end
    end

    def delete
      self.class.collection.delete(self.id)
    end

    module ClassMethods
      def create *args, &block
        collection[args[0]] = new(*args, &block)
      end

      def collection
        @collection ||= {}
      end

      def [] *items
        items.first.is_a?(Array) ? find_many(*items) : find_one(items.first)
      end

      def find_one item
        collection[item] || find{ |i| i.name == item }
      end

      def find_many *items
        items.flatten!
        items.map{ |i| find_one(i) }.compact.uniq
      end

      def find_or_create_by hash
        find_one(hash[:id] || hash[:name]) || create(hash)
      end

      protected

      def method_missing name, *args, &block
        return collection.values.public_send(name, *args, &block) if Array.instance_methods.include?(name)
        super
      end
    end
  end
end

