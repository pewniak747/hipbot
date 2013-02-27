module Hipbot
  class Collection < Struct.new(:id, :name, :params)
    private_class_method :new
    alias_method :to_s, :name

    def initialize *args
      super
      self.params = OpenStruct.new(params)
    end

    def delete
      self.class.collection.delete(self.id)
    end

    class << self
      attr_accessor :bot

      def create *args, &block
        collection[args[0]] = new(*args, &block)
      end

      def collection
        @collection ||= {}
      end

      def [] item
        collection[item] || collection.find{ |_, i| i.name == item }.try(:last)
      end

      protected

      def method_missing name, *args, &block
        return collection.public_send(name, *args, &block) if collection.respond_to?(name)
        super
      end
    end
  end
end

