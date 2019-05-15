module Ubiquity
  class SharedIndexSolrServiceWrapper
    attr_accessor :solr_document, :action_type, :tenant_cname

    def initialize(solr_document, action_type, tenant_cname)
      @solr_document = solr_document
      @action_type = action_type
      @tenant_cname = tenant_cname
    end

    def update
      AccountElevator.switch!(tenant_cname)
      if action_type == "add"
        add_record
      elsif action_type == "remove"
        remove_record
      end
    end

    private

    def add_record
      service = ActiveFedora::SolrService
      #softCommit first commits to memory then to disk
      service.add(solr_document, softCommit: true)
      service.commit
    end

    def remove_record
      service = ActiveFedora::SolrService
      service.delete(solr_document[:id])
      service.commit
    end

  end
end
