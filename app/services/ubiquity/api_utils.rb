module Ubiquity
  class ApiUtils
    def self.query_for_collection_works(collection)
      if collection.present?
        cache_key = "child_works/#{collection['account_cname_tesim'].first}/#{collection['id']}/#{collection['system_modified_dtsi']}"
        works = Rails.cache.fetch(cache_key) do
          CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection['id']}", rows: 200,  "sort" => "score desc, system_modified_dtsi desc",
          fq: ["({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", "", "-suppressed_bsi:true"]
          )
        end
        works['response']['docs']
      else
        [ ]
      end
    end

    def self.query_for_parent_collections(work, skip_run = nil)
      if work.present? && work["member_of_collection_ids_ssim"].present? &&  skip_run == 'true'
        cache_key = "parent_collection/#{work['account_cname_tesim'].first}/#{work['id']}/#{work["member_of_collection_ids_ssim"].try(:size).to_i}/#{work['system_modified_dtsi']}"
        parent_collections = Rails.cache.fetch(cache_key) do
          collection_ids = work["member_of_collection_ids_ssim"].presence
          collections_list = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{collection_ids.join(',')}",
            "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", "", "-suppressed_bsi:true"
          ])
          collections_list['response']['docs'].map do |doc|
            {uuid: doc['id'], title: doc['title_tesim'].try(:first)}
          end
        end
        parent_collections
      else
        [ ]
      end
    end

    def self.query_for_files(work, skip_run = nil)
      if work.present? && work['file_set_ids_ssim'].present? && skip_run == 'true'
        cache_key = "work_files/#{work['account_cname_tesim'].first}/#{work['id']}/#{work["file_set_ids_ssim"].try(:size).to_i}/#{work['system_modified_dtsi']}"
        child_files = Rails.cache.fetch(cache_key) do
          file_ids = work['file_set_ids_ssim'].join(',')
          work_files = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{file_ids}",
           "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", "", "-suppressed_bsi:true"
           ], rows: 200,  "sort" => "score desc, system_modified_dtsi desc")

          file_count = work_files['response']['numFound']
          summary = work_files['response']['docs'].group_by {|hash| hash['visibility_ssi']}.transform_values(&:count)
          summary.merge(total: file_count)
        end
        child_files
      else
        [ ]
      end
    end

    def self.fetch_and_covert_thumbnail_to_base64_string(record, skip_run = nil)
      host_array = record['account_cname_tesim'].first && record['account_cname_tesim'].first.split('.')
      if record['thumbnail_path_ss'].present? && (host_array.include?('localhost')) && record['visibility_ssi'] == 'open'
        get_thumbnail_from_fedora(record)
      elsif record['thumbnail_path_ss'].present? && record['visibility_ssi'] == 'open'
        base64_image_from_string_io(record)
      else
        nil
      end
    end

    private

    def self.base64_image_from_string_io(record)
      host_array = record['account_cname_tesim'].first && record['account_cname_tesim'].first.split('.')
      cache_type = record.fetch('has_model_ssim').try(:first) == 'Collection' ? 'fedora/collection' : 'fedora/work'
      image_string = Rails.cache.fetch("single/#{cache_type}-thumbnail/#{record.fetch('account_cname_tesim').first}/#{record['id']}") do
        url = ('https://' + record['account_cname_tesim'].first + record['thumbnail_path_ss'])
        string_io = open(url)
        file_content = string_io.read
        base64_img_str = Base64.strict_encode64(file_content)
      end

     rescue Errno::ENOENT, StandardError => e
      puts "file-path--missing-error reading a thumbnail file. #{e.inspect}"
      nil
    end

    def self.get_thumbnail_from_fedora(record)
      cname = record['account_cname_tesim'].first
      AccountElevator.switch!(cname)
      cache_type = record.fetch('has_model_ssim').try(:first) == 'Collection' ? 'fedora/collection' : 'fedora/work'
      get_work = get_work_from_fedora(record, cache_type)
      if get_work && get_work.visibility == 'open' && get_work.thumbnail.present? && get_work.thumbnail.visibility == 'open'
        thumbnail_string = Rails.cache.fetch("single/#{cache_type}-thumbnail/#{record.fetch('account_cname_tesim').first}/#{record['id']}") do
          file = get_work.thumbnail
          file_path =  Hyrax::DerivativePath.derivative_path_for_reference(file, 'thumbnail')
          file_content = File.read(file_path)
          Base64.strict_encode64(file_content)
        end
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
        Rails.cache.fetch("single/#{cache_type}/#{record.fetch('account_cname_tesim').first}/#{record['id']}") do
             ActiveFedora::Base.find(record['id'])
        end
      else
        nil
      end
    end

  end
end
