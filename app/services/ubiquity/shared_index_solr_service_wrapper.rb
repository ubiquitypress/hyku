module Ubiquity
  class SharedIndexSolrServiceWrapper
    attr_accessor :solr_document, :action_type, :tenant_cname, :file_set_doc

    def initialize(solr_document, action_type, tenant_cname, file_set_doc = nil)
      @solr_document = solr_document
      @action_type = action_type
      @file_set_doc = file_set_doc
      @tenant_cname = tenant_cname
    end

    def update
      AccountElevator.switch!(tenant_cname)
      if action_type == "add"
        add_record
        index_file_set
      elsif action_type == "remove"
        remove_record
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
      if file_set_doc.present?
        #this is not an rsolr coonection but it calls it
        service = ActiveFedora::SolrService
        service.add(file_set_doc, softCommit: true)
        service.commit
      end
    end

    def remove_record
      #get rsolr connection
      service = ActiveFedora::SolrService.instance.conn

      if solr_document.class == Hash
        service.delete_by_id(solr_document[:id])
      else
        ids = solr_document.map { |hash| hash[:id] }
        #an rsolr method
        service.delete_by_id(ids)
      end
      service.commit
    end

  end
end
