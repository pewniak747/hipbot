module Hipbot
  module Collection
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
      attr_reader  :id, :name, :attributes
      alias_method :to_s, :name
    end

    def initialize args
      @id     = args.delete(:id)
      @name   = args.delete(:name)
      @attributes = OpenStruct.new(args)
    end

    def update_attribute key, value
      @attributes[key] = value
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

      protected

      def method_missing name, *args, &block
        return collection.values.public_send(name, *args, &block) if Array.instance_methods.include?(name)
        super
      end
    end
  end
end

