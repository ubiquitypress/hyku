module Ubiquity
  class ApiUtils

    #   #collection is a solr_document or  a hash
    def self.query_for_collection_works(collection, user = nil)
     if collection.present?
       cache_key = "child_works/#{collection['account_cname_tesim'].first}/#{collection['id']}/#{collection['system_modified_dtsi']}"
       #works = Rails.cache.fetch(cache_key) do
         using_works_in_collecton = fetch_works_in_collection_member_objects(collection, user)
         using_collection_ids_in_works= fetch_work_using_collection_ids_stored_in_work_metadatafield(collection, user)

         combined_record =  using_works_in_collecton['response']['docs'] | using_collection_ids_in_works['response']['docs']
         using_collection_ids_in_works['response']['docs'] = combined_record
         using_collection_ids_in_works['response']['numFound'] = combined_record.size
         using_collection_ids_in_works
      #end
       using_collection_ids_in_works['response']['docs']
       #works['response']['docs']
     else
       [ ]
     end
   end

   #collection is a solr_document or  a hash
   def self.group_collection_works_by_volumes(collection, options = {})
     group_limit = options['group_limit'] || 3000
     field = options['group_parent_field']
     child_group = options['group_child_field'] || "issue_tesim"
     if collection.present?
       id = collection.with_indifferent_access['id']
       cache_key = "works_by_volumes/#{collection['account_cname_tesim'].first}/#{id}/#{collection['system_modified_dtsi']}/#{field}/#{group_limit}"
       #works = Rails.cache.fetch(cache_key) do
          response = CatalogController.new.repository.search({ q: '', fl: 'issue_tesim, volume_tesim, title_tesim, id', fq: ['has_model_ssim:ArticleWork', "{!terms f=collection_id_sim}#{id}"],
            'group.field': field, 'group.query': "#{child_group}:[* TO *]", 'group.facet': true, group: true, rows: 3000, 'group.limit': group_limit })

         response_volume_grouping = response["grouped"]['volume_tesim']['groups']
         remap_response_by_volumes(response_volume_grouping)
       #end
     end
   end

   def self.query_for_parent_collections(work, skip_run = nil)
     member_of_collection_ids = work["member_of_collection_ids_ssim"] || []
     collection_id_in_works = work["collection_id_tesim"] || []
     combined_collection_ids = collection_id_in_works | member_of_collection_ids 
     if work.present? && combined_collection_ids.present?  &&  skip_run == 'true'

       cache_key = "parent_collection/#{work['account_cname_tesim'].first}/#{work['id']}/#{combined_collection_ids.try(:size).to_i}/#{work['system_modified_dtsi']}"

       #parent_collections = Rails.cache.fetch(cache_key) do
            collection_ids = combined_collection_ids
            collections_list = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{collection_ids.join(',')}"
            ])
            collections_list['response']['docs'].map do |doc|
              {uuid: doc['id'], title: doc['title_tesim'].try(:first)}
            end
       #end
       #parent_collections
     else
       [ ]
     end
   end

   def self.query_for_files(work, skip_run = nil)
     if work.present? && work['file_set_ids_ssim'].present? && skip_run == 'true'
       cache_key = "work_files/#{work['account_cname_tesim'].first}/#{work['id']}/#{work["file_set_ids_ssim"].try(:size).to_i}/#{work['system_modified_dtsi']}"
       #child_files = Rails.cache.fetch(cache_key) do
         file_ids = work['file_set_ids_ssim'].join(',')
         work_files = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{file_ids}"], rows: 100,  "sort" => "score desc, system_modified_dtsi desc")
          #child_files  #['response']['docs']
         file_count = work_files['response']['numFound']
         summary = work_files['response']['docs'].group_by {|hash| hash['visibility_ssi']}.transform_values(&:count)
         summary.merge(total: file_count)
       #end
       #child_files
     else
       [ ]
     end
   end

   def self.fetch_and_covert_thumbnail_to_base64_string(record, skip_run = nil)
     if skip_run == 'true' && record['thumbnail_path_ss'].present?
       get_thumbnail_from_fedora(record)
     end
   end

    private

    def self.get_thumbnail_from_fedora(record)
       cname = record['account_cname_tesim'].first
       AccountElevator.switch!(cname)
       cache_type = record.fetch('has_model_ssim').try(:first) == 'Collection' ? 'fedora/collection' : 'fedora/work'
       get_work = get_work_from_fedora(record, cache_type)
       if get_work && get_work.visibility == 'open' && get_work.thumbnail.present? && get_work.thumbnail.visibility == 'open'
          #thumbnail_string = Rails.cache.fetch("single/#{cache_type}-thumbnail/#{record.fetch('account_cname_tesim').first}/#{record['id']}") do
          file = get_work.thumbnail
          file_path =  Hyrax::DerivativePath.derivative_path_for_reference(file, 'thumbnail')
          file_content = File.read(file_path)
          thumbnail_string = Base64.strict_encode64(file_content)
         #end
      thumbnail_string
       else
         nil
       end
     rescue Errno::ENOENT, StandardError => e
       puts "file-path--missing-error reading a thumbnail file. #{e.inspect}"
       nil
    end

    def self.get_work_from_fedora(record, cache_type)
       if record.fetch('account_cname_tesim').present?
          #Rails.cache.fetch("single/#{cache_type}/#{record.fetch('account_cname_tesim').first}/#{record['id']}") do
             ActiveFedora::Base.find(record['id'])
          #end
       else
         nil
       end
    end

    def self.fetch_works_in_collection_member_objects(collection, user)
      if user.present?
        CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection['id']}", rows: 200,  "sort" => "score desc, system_modified_dtsi desc",
         fq: filter_visibility(user) )
      else
        CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection['id']}", rows: 200,  "sort" => "score desc, system_modified_dtsi desc",
         fq: filter_visibility )
      end
    end

    def self.fetch_work_using_collection_ids_stored_in_work_metadatafield(collection, user)
      if user.present?
        CatalogController.new.repository.search(q: "collection_id_sim:#{collection['id']}", rows: 200,  "sort" => "score desc, system_modified_dtsi desc",
          fq: filter_visibility(user) )
      else
        CatalogController.new.repository.search(q: "collection_id_sim:#{collection['id']}", rows: 200,  "sort" => "score desc, system_modified_dtsi desc",
          fq: filter_visibility )
      end
    end

    def self.filter_visibility(user = nil)
      current_ability = Ability.new(user)
      if user && current_ability.admin?
        ["-suppressed_bsi:true"]

      elsif user && user.user_key.present?
        ["({!terms f=edit_access_group_ssim}public,registered) OR ({!terms f=discover_access_group_ssim}public,registered) OR ({!terms f=read_access_group_ssim}public,registered) OR
           edit_access_person_ssim:#{user.user_key} OR discover_access_person_ssim:#{user.user_key} OR read_access_person_ssim:#{user.user_key}", "-suppressed_bsi:true", ""]

      elsif user.nil?
        ["({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", ""]
      end
    end

    def self.remap_response_by_volumes(response_data)
      response_array = []
      response_hash = {label: '', children: [] }
      response_data.each do |h|
        h['doclist']['docs'].each do |ch|
          response_hash[:label] = "Volume #{h['groupValue']}"
          response_hash[:children] << {label:  "Issue #{ch['issue_tesim'].try(:first)}",
                                       data: {issue: "#{ch['issue_tesim'].try(:first)}", volume: "#{ch['volume_tesim'].try(:first)}"}
                                     }

          response_hash[:children].uniq!
          response_array << response_hash
        end
      end
      response_array.uniq!
    end

  end
end
