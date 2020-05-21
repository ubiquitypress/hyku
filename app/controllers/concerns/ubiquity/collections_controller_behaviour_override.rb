module Ubiquity
  module CollectionsControllerBehaviourOverride
    extend ActiveSupport::Concern

    private

    # Queries Solr for members of the collection.
    # Populates @response and @member_docs similar to Blacklight Catalog#index populating @response and @documents
    def query_collection_members
      params[:q] = params[:cq]
      if helpers.check_should_not_use_fedora_association(request.original_url) == "true"
        @response = query_for_work_using_collection_id
        unless @response.empty?
          @member_docs = @response.documents
        end
      else
         @response = repository.search(query_for_collection_members)
         @member_docs = @response.documents
      end

    end

    def query_for_work_using_collection_id
      #Note that collection is Hyrax::CollectionPresenter object returned when collection is cliacked on the homepage
      #while @collection is an of collection model returned when collection is clicked from the dashboard
      collection_id = @collection.try(:id) || collection.try(:id)

      @fetching_with_collection_id ||= repository.search(q: "collection_id_sim:#{collection_id}", rows: 2500)
      if @fetching_with_collection_id['response']['docs'].present?
        @fetching_with_collection_id
      else
        []
      end
    end

  end
end
