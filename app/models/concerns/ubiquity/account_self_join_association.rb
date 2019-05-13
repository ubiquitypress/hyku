module Ubiquity
  module AccountSelfJoinAssociation
    extend ActiveSupport::Concern
    included do
      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true
    end
  end
end

Account.class_eval do
  include Ubiquity::AccountSelfJoinAssociation
end
