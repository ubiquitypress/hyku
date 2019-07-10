module Ubiquity
  class SharedIndexSolrServiceWrapper
    attr_accessor :data, :action_type, :tenant_cname, :add_to_in_shared_search

    def initialize(data, action_type, tenant_cname, add_to_in_shared_search = nil)
      @data = data
      @action_type = action_type
      @tenant_cname = tenant_cname
      @add_to_in_shared_search = add_to_in_shared_search
    end

    def update
      if action_type == "add" && add_to_in_shared_search == 'true'
        puts "olly #{data.inspect}"
        #data here is a solr_document
        add_record
      elsif action_type == "remove"
        #data here is a solr_socument id
        remove_record
      end
    end

    private

    def add_record
      AccountElevator.switch!(tenant_cname)
      puts "executing add_record method in Ubiquity:: SharedIndexSolrServiceWrapper with  - #{data.inspect}"
      service = ActiveFedora::SolrService
        #data here is a solr_socument
      #softCommit first commits to memory then to disk
      service.add(data, softCommit: true)
      service.commit
    end

    def remove_record
      puts "executing add_record method in Ubiquity:: SharedIndexSolrServiceWrapper with  - #{data.inspect}"
      AccountElevator.switch!(tenant_cname)
      service = ActiveFedora::SolrService.instance.conn
      if data.class == Hash
        puts "hash data for removal #{data.inspect}"
       #solr_conn.delete_by_id(data['id'])
      service.delete_by_id(data.with_indifferent_access['id'])

     elsif data.class == Array
       puts "array of data for removal from shared search #{data.inspect}"
        #ids = data.map { |hash| hash.with_indifferent_access['id'] }
        ids = data.map { |id| id if id.class == String}.compact
        #an rsolr method
        service.delete_by_id(ids)
      else
        puts "string id for removal from shared search #{data.inspect}"
        service.delete_by_id(data)
      end
      service.commit
    end

  end
end
