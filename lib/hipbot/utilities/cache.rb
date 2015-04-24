module Hipbot
  module Cache
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    def _cache
      @_cache ||= {}
    end

    module ClassMethods
      def attr_cache *attributes, &block
        attributes.each do |attr_name|
          define_method(attr_name) do
            _cache[attr_name] ||= block_given? ? instance_eval(&block) : []
          end
        end
      end
    end
  end
end
