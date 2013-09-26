module Hipbot
  module Configurable
    extend ActiveSupport::Concern
    attr_accessor :configuration

    delegate *Configuration::OPTIONS, to: :configuration

    included do
      extend ClassMethods
    end

    def initialize
      self.configuration ||= Configuration.new
    end

    module ClassMethods
      def configure &block
        instance.configuration = Configuration.new.tap(&block)
      end
    end
  end
end
