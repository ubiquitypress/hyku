module Ubiquity
  class ApiUtils
    def self.query_for_collection_works(collection_id)
      if collection_id
        works = CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection_id}", rows: 200,  "sort" => "score desc, system_modified_dtsi desc",
          fq: ["({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", "", "-suppressed_bsi:true"]
        )
        works['response']['docs']
      else
        [ ]
      end
    end

    def self.query_for_parent_collections(collection_ids, skip_run = nil)
      if collection_ids.present? && skip_run == 'true'
        parent_collections = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{collection_ids.join(',')}",
          "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", "", "-suppressed_bsi:true"

          ])
        parent_collections['response']['docs'].map do |doc|
          {uuid: doc['id'], title: doc['title_tesim'].try(:first)}
        end
      else
        [ ]
      end
    end

    def self.query_for_files(file_ids, skip_run = nil)
      if file_ids.present? && skip_run == 'true'
        child_files = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{file_ids.join(',')}",
          "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", "", "-suppressed_bsi:true"
          ], rows: 200,  "sort" => "score desc, system_modified_dtsi desc")
        child_files  #['response']['docs']
        file_count = child_files['response']['numFound']
        summary = child_files['response']['docs'].group_by {|hash| hash['visibility_ssi']}.transform_values(&:count)
        summary.merge(total: file_count)
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
     if record.fetch('account_cname_tesim').present? && get_thumbnail_string = 'true'
        cache_type = record.fetch('has_model_ssim').try(:first) == 'Collection' ? 'fedora/collection' : 'fedora/work'
        get_work = Rails.cache.fetch("single/#{cache_type}/#{record.fetch('account_cname_tesim').first}/#{record['id']}") do
           ActiveFedora::Base.find(record['id'])

        end
     else
       get_work = nil
     end
     if get_work && get_work.visibility == 'open' && get_work.thumbnail.present? && get_work.thumbnail.visibility == 'open'
       file = get_work.thumbnail
       file_path =  Hyrax::DerivativePath.derivative_path_for_reference(file, 'thumbnail')
       file_content = File.read(file_path)
       Base64.strict_encode64(file_content)
     else
       nil
     end
   rescue Errno::ENOENT, StandardError => e
     puts "file-path--missing-error reading a thumbnail file. #{e.inspect}"
     nil
  end

   def self.fetch_thumbnail_from_fedora(file_set)
     #cname = record['account_cname_tesim'].first
     cname = file_set.try(:account_cname)
     AccountElevator.switch!(cname)
     #get_work = ActiveFedora::Base.find(record['id'])
     if file_set.try(:visibility) == 'open'
       file_path =  Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')
       file_content = File.read(file_path)
       Base64.strict_encode64(file_content)
     else
       nil
     end
   rescue Errno::ENOENT, StandardError => e
     puts "file-path--missing-error reading a thumbnail file for #{file_set}. #{e.inspect}"
     nil
   end

  end
end
