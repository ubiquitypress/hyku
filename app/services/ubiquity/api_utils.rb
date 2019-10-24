module Ubiquity
  class ApiUtils
    def self.query_for_colection_works(collection_id)
      if collection_id
        works = CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection_id}")
        works['response']['docs']
      else
        [ ]
      end
    end

    def self.query_for_parent_collections(collection_ids)
      if collection_ids.present?
        parent_collections = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{collection_ids.join(',')}"])
        parent_collections['response']['docs'].map do |doc|
          {uuid: doc['id'], title: doc['title_tesim'].try(:first)}
        end
      else
        [ ]
      end
    end

    def self.query_for_files(file_ids)
      if file_ids.present?
        child_files = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{file_ids.join(',')}"])
        child_files  #['response']['docs']
        file_count = child_files['response']['numFound']
        summary = child_files['response']['docs'].group_by {|hash| hash['visibility_ssi']}.transform_values(&:count)
        summary.merge(total: file_count)
      else
        [ ]
      end
    end

    def self.query_for_file_licence(file_id)
      if file_id.present?
        child_files = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{file_id}"])
        child_files['response']['docs'].map do |doc|
          {uuid: doc['id'], licence: doc['license_tesim']}
        end
      else
        [ ]
      end
    end

  end
end
