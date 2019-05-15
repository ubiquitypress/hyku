module Ubiquity
  module AccountSelfJoinAssociation
    extend ActiveSupport::Concern
    included do
      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings
    end
  end
end
