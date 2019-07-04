module Ubiquity
  class SharedIndexSolrServiceWrapper
    attr_accessor :solr_document, :action_type, :tenant_cname, :file_sets, :add_to_in_shared_search

    def initialize(solr_document, action_type, tenant_cname, file_sets = nil, add_to_in_shared_search = nil)
      @solr_document = solr_document
      @action_type = action_type
      @file_sets = file_sets
      @tenant_cname = tenant_cname
      @add_to_in_shared_search = add_to_in_shared_search
    end

    def update
      AccountElevator.switch!(tenant_cname)
      if action_type == "add" && add_to_in_shared_search == 'true'
        add_record
        index_file_set
      elsif action_type == "remove"
        remove_record
        remove_work_file_set_from_index
      end
    end

    def self.deindex_work(solr_document, parent_cname)
      new(solr_document, 'remove', parent_cname).update
    end

    private

    def add_record
      service = ActiveFedora::SolrService
      #softCommit first commits to memory then to disk
      service.add(solr_document, softCommit: true)
      service.commit
    end

    def index_file_set
      if file_sets.present?
        #this is not an rsolr coonection but it calls it
        service = ActiveFedora::SolrService
        file_sets.each do |file_set_doc|
          service.add(file_set_doc, softCommit: true)
        end
        service.commit
      end
    end

    def remove_record
      service = ActiveFedora::SolrService.instance.conn
      puts "sera #{service.inspect}"
       puts "lima #{solr_document.inspect}"
      if solr_document.class == Hash
        puts "loku #{solr_document['id'].inspect}"
       #solr_conn.delete_by_id(solr_document['id'])
        service.delete_by_id(solr_document.with_indifferent_access['id'])
      else
        ids = solr_document.map { |hash| hash.with_indifferent_access['id'] }
        #an rsolr method
        service.delete_by_id(ids)
      end
      service.commit
    end




  end
end
