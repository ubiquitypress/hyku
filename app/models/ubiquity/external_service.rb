class Ubiquity::ExternalService < ApplicationRecord
  belongs_to :account
  validates :draft_doi,  uniqueness: {scope: :account_id}
end
