class ExternalService < ApplicationRecord
  #property column is an array
  store_accessor :property
  #data column is a hash & the hash keys are :api_type, :status_code, :request_type
  store_accessor :data, :api_type, :status_code, :request_type, :tenant_name
  validates :draft_doi,  uniqueness: true
  validates :api_type, presence: true
end
