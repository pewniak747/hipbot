module Hipbot
  module Storages
    module Mongoid
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document

        field :_id,  type: String
        field :name, type: String

        alias_method :to_s, :name

        validates :name, presence: true
      end
    end
  end
end
