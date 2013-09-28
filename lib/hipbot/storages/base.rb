module Hipbot
  module Storages
    module Base
      extend ActiveSupport::Concern

      included do
        extend ClassMethods
        alias_method :to_s, :name
      end

      def initialize attributes
        raise NotImplementedError
      end

      def attributes
        raise NotImplementedError
      end

      def destroy
        raise NotImplementedError
      end

      def id
        raise NotImplementedError
      end

      def name
        raise NotImplementedError
      end

      def name= value
        raise NotImplementedError
      end

      def update_attribute key, value
        raise NotImplementedError
      end

      def update_attributes attributes
        raise NotImplementedError
      end

      module ClassMethods
        def all
          raise NotImplementedError
        end

        def create attributes
          raise NotImplementedError
        end

        def find id
          raise NotImplementedError
        end

        def find_by attributes
          raise NotImplementedError
        end

        def find_or_create_by attributes
          raise NotImplementedError
        end

        def find_or_initialize_by attributes
          raise NotImplementedError
        end

        def new attributes
          raise NotImplementedError
        end

        def where attributes
          raise NotImplementedError
        end
      end
    end
  end
end
