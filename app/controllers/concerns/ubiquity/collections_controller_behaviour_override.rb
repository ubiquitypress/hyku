module Ubiquity
  module CollectionsControllerBehaviourOverride
    private

    # Queries Solr for members of the collection.
    # Populates @response and @member_docs similar to Blacklight Catalog#index populating @response and @documents
    def query_collection_members
      params[:q] = params[:cq]
      @response = repository.search(query_for_collection_members)
      @member_docs = @response.documents | query_for_work_using_collection_id
    end

    def query_for_work_using_collection_id
      fetching_with_collection_id = repository.search(q: "collection_id_sim:#{collection['id']}")
      if fetching_with_collection_id['response']['docs'].present?
        fetching_with_collection_id['response']['docs'].map {|h| SolrDocument.new(h, current_ability)}
      else
        []
      end
    end

  end
end
