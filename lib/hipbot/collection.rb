module Hipbot
  class Collection
    private_class_method :new
    attr_reader  :id, :name
    alias_method :to_s, :name

    def initialize args
      @id     = args.delete(:id)
      @name   = args.delete(:name)
      @params = OpenStruct.new(args)
    end

    def set_param key, value
      @params[key] = value
    end

    def delete
      self.class.collection.delete(self.id)
    end

    class << self
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

