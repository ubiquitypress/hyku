module Ubiquity
  module GlobalSharedMetadataControllersBehaviour
    extend ActiveSupport::Concern

    def update
      update_contributor_meta_field
      update_creator_meta_field
      super
    end

    def create
      create_contributor_meta_field
      create_creator_meta_field
      super
    end

    private

    def update_contributor_meta_field
      #params[hash_key_for_curation_concern].merge!("contributor_group" => [{"contributor_list" => params[hash_key_for_curation_concern]["contributor_list"], "contributor_id" => params[hash_key_for_curation_concern]["contributor_id"], "contributor_name" => params[hash_key_for_curation_concern]["contributor_name"] }])



      list = {"contributor_type" => params[hash_key_for_curation_concern]["contributor_type"] }
      new_id = {"contributor_orcid" => params[hash_key_for_curation_concern]["contributor_orcid"] }
      new_name = {"contributor_given_name" => params[hash_key_for_curation_concern]["contributor_given_name"]}
      name_type = {"contributor_name_type" => params[hash_key_for_curation_concern]["contributor_name_type"] }
      new_isni = {"contributor_isni" => params[hash_key_for_curation_concern]["contributor_isni"] }
      new_family_name = {"contributor_family_name" => params[hash_key_for_curation_concern]["contributor_family_name"]}


      added_hash = list.merge(new_id).merge(new_name).merge(name_type).merge(new_isni).merge(new_family_name).to_json

      params[hash_key_for_curation_concern].merge!({"contributor_group" => [added_hash]})

      params[hash_key_for_curation_concern].merge!({"contributor" => [added_hash]})

      puts "update-listo   #{list}"
      puts "update_name #{new_name}"

      puts "up-datemy-params: #{params[hash_key_for_curation_concern]}"

      params

    end

    def create_contributor_meta_field
      #params[hash_key_for_curation_concern].merge!("contributor_group" => [{"contributor_list" => params[hash_key_for_curation_concern]["contributor_list"], "contributor_id" => params[hash_key_for_curation_concern]["contributor_id"], "contributor_name" => params[hash_key_for_curation_concern]["contributor_name"] }])

      list = {"contributor_type" => params[hash_key_for_curation_concern]["contributor_type"] }
      new_id = {"contributor_orcid" => params[hash_key_for_curation_concern]["contributor_orcid"] }
      new_name = {"contributor_given_name" => params[hash_key_for_curation_concern]["contributor_given_name"]}

      name_type = {"contributor_name_type" => params[hash_key_for_curation_concern]["contributor_name_type"] }
      new_isni = {"contributor_isni" => params[hash_key_for_curation_concern]["contributor_isni"] }
      new_family_name = {"contributor_family_name" => params[hash_key_for_curation_concern]["contributor_family_name"]}


      added_hash = list.merge(new_id).merge(new_name).merge(name_type).merge(new_isni).merge(new_family_name).to_json

      #params[hash_key_for_curation_concern].merge!({"contributor_group" => [added_hash]})
      params[hash_key_for_curation_concern].merge!({"contributor" => [added_hash]})

      puts "update-listo   #{list}"
      puts "update_name #{new_name}"
      puts "up-datemy-params: #{params[hash_key_for_curation_concern]}"
      params

    end

    
    def update_creator_meta_field
      #params[hash_key_for_curation_concern].merge!("creator_group" => [{"creator_list" => params[hash_key_for_curation_concern]["creator_list"], "creator_id" => params[hash_key_for_curation_concern]["creator_id"], "creator_name" => params[hash_key_for_curation_concern]["creator_name"] }])

=begin
      list = {"creator_type" => params[hash_key_for_curation_concern]["creator_type"] }
      new_id = {"creator_orcid" => params[hash_key_for_curation_concern]["creator_orcid"] }
      new_name = {"creator_given_name" => params[hash_key_for_curation_concern]["creator_given_name"]}
      name_type = {"creator_name_type" => params[hash_key_for_curation_concern]["creator_name_type"] }
      new_isni = {"creator_isni" => params[hash_key_for_curation_concern]["creator_isni"] }
      new_family_name = {"creator_family_name" => params[hash_key_for_curation_concern]["creator_family_name"]}


      added_hash = list.merge(new_id).merge(new_name).merge(name_type).merge(new_isni).merge(new_family_name).to_json

      #params[hash_key_for_curation_concern].merge!({"creator_group" => [added_hash]})

     #in use #params[hash_key_for_curation_concern].merge!({"creator" => [added_hash]})

      puts "update-listo   #{list}"
      puts "update_name #{new_name}"
=end

      new_creator = params[hash_key_for_curation_concern]["creator"].to_json

      params[hash_key_for_curation_concern].merge!({"creator" => [new_creator]})

      puts "up-datemy-params: #{params[hash_key_for_curation_concern]}"
      params

    end

    def create_creator_meta_field
      #params[hash_key_for_curation_concern].merge!("creator_group" => [{"creator_list" => params[hash_key_for_curation_concern]["creator_list"], "creator_id" => params[hash_key_for_curation_concern]["creator_id"], "creator_name" => params[hash_key_for_curation_concern]["creator_name"] }])

      list = {"creator_type" => params[hash_key_for_curation_concern]["creator_type"] }
      new_id = {"creator_orcid" => params[hash_key_for_curation_concern]["creator_orcid"] }
      new_name = {"creator_given_name" => params[hash_key_for_curation_concern]["creator_given_name"]}

      name_type = {"creator_name_type" => params[hash_key_for_curation_concern]["creator_name_type"] }
      new_isni = {"creator_isni" => params[hash_key_for_curation_concern]["creator_isni"] }
      new_family_name = {"creator_family_name" => params[hash_key_for_curation_concern]["creator_family_name"]}


      added_hash = list.merge(new_id).merge(new_name).merge(name_type).merge(new_isni).merge(new_family_name).to_json

      #params[hash_key_for_curation_concern].merge!({"creator_group" => [added_hash]})
      params[hash_key_for_curation_concern].merge!({"creator" => [added_hash]})

      puts "update-listo   #{list}"
      puts "update_name #{new_name}"
      puts "up-datemy-params: #{params[hash_key_for_curation_concern]}"
      params

    end

  end

end
