module Ubiquity
  class SharedIndexSolrServiceWrapper
    attr_accessor :data, :action_type, :tenant_cname, :file_sets

    def initialize(data, action_type, tenant_cname, file_sets = nil)
      @data = data
      @action_type = action_type
      @file_sets = file_sets
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

    private

    def add_record
      service = ActiveFedora::SolrService
      #softCommit first commits to memory then to disk
      service.add(data, softCommit: true)
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
      puts "executing add_record method in Ubiquity:: SharedIndexSolrServiceWrapper with  - #{data.inspect}"
      AccountElevator.switch!(tenant_cname)
      service = ActiveFedora::SolrService.instance.conn
      if data.class == Hash
        puts "hash data for removal #{data.inspect}"
        #solr_conn.delete_by_id(data['id'])
        service.delete_by_id(data.with_indifferent_access['id'])
      elsif data.class == Array
        puts "array of data for removal from shared-search #{data.inspect}"
        #ids = data.map { |hash| hash.with_indifferent_access['id'] }
        ids = data.map { |id| id if id.class == String}.compact
        #an rsolr method
         service.delete_by_id(ids)
      else
        puts "string id for removal from shared-search #{data.inspect}"
        service.delete_by_id(data)
      end
      service.commit
    end

  end
end
