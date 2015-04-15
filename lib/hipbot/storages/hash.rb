module Hipbot
  module Storages
    module Hash
      extend ActiveSupport::Concern

      included do
        extend ClassMethods

        attr_accessor :attributes
        alias_method :to_s, :name
      end

      def initialize params = {}
        self.attributes = params.with_indifferent_access
      end

      def id
        attributes[:id]
      end

      def name
        attributes[:name]
      end

      def name= value
        update_attribute(:name, value)
      end

      def update_attribute key, value
        self.attributes[key] = value
      end

      def update_attributes hash
        hash.each do |k, v|
          update_attribute k, v
        end
      end

      def destroy
        self.class.collection.delete(id)
      end

      module ClassMethods
        include Cache

        def all
          collection.values
        end

        def create params
          collection[params[:id]] = new(params)
        end

        attr_cache :collection do
          {}
        end

        def find_or_create_by params
          find_by(params) || create(params)
        end

        def find_or_initialize_by params
          find_by(params) || self.new(params)
        end

        def find_by params
          where(params).first
        end

        def find id
          where(id: id).first
        end

        def where param
          collection.values.select do |item|
            param.all?{ |k, v| item.attributes[k] == v }
          end
        end

        # protected

        # def method_missing name, *args, &block
        #   return all.public_send(name, *args, &block) if Array.instance_methods.include?(name)
        #   super
        # end
      end
    end
  end
end
