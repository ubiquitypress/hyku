class ExternalService < ApplicationRecord
   validates :draft_doi,  uniqueness: true
   attr_accessor :tenant_name
end
