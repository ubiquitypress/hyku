module Ubiquity
  module AllModelsVirtualFields
    extend ActiveSupport::Concern

    included do

      before_save  :save_contributor
      before_save :save_creator

      attr_accessor :contributor_group, :contributor_name_type, :contributor_type, :contributor_given_name,
                  :contributor_family_name, :contributor_orcid, :contributor_isni,
                  :contributor_position

      attr_accessor :creator_group, :creator_name_type, :creator_name, :creator_given_name,
                      :creator_family_name, :creator_orcid, :creator_isni,
                      :creator_position

    end

    private

    #remove hash keys with value of nil, "", and "NaN"
    def remove_hash_keys_with_empty_and_nil_values(data)
      data.map do |hash|
         hash.reject { |k,v| v.nil? || v.empty? ||v == "NaN" }
      end
    end

    def save_creator
      if !self.creator_group.nil?
        new_creator_group = remove_hash_keys_with_empty_and_nil_values(self.creator_group)

        creator_json = new_creator_group.to_json

        self.creator = [creator_json]
      end
    end

    def save_contributor
      if !self.contributor_group.nil?
        new_contributor_group = remove_hash_keys_with_empty_and_nil_values(self.contributor_group)
        puts "kon #{new_contributor_group}"
        contributor_json = new_contributor_group.to_json
        puts "pop #{contributor_json}"
        contributor_json
      end

      self.contributor = [contributor_json]
    end

  end
end
