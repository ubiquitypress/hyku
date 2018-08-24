module Ubiquity
  module AllModelsVirtualFields
    extend ActiveSupport::Concern

    included do

             
      attr_accessor :contributor_name_type, :contributor_type, :contributor_given_name,
                  :contributor_family_name, :contributor_orcid, :contributor_isni,
                  :contributor_position 

      attr_accessor :creator_name_type, :creator_name, :creator_given_name,
                      :creator_family_name, :creator_orcid, :creator_isni,
                      :creator_position

    end
  end
end
