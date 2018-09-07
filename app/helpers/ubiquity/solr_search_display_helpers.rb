module Ubiquity
  module SolrSearchDisplayHelpers
      #When this is called from CatalogController via config.add_index_field solr_name("creator"), helper_method: :display_creator_fields_in_search, label: "Creator"
      #it gives you access to an instance of solr document which is what options represent
      #Therefor options[:value][0] represents the json value stored in the creator metadata field but in solr called creator_tesim
      def display_creator_fields_in_search(options={})
        data ||= pass_model(options)
        #source: 'search' is temporal and for now it stops multiple labels for linked  metadata on the search page
        render "shared/ubiquity/creator/show", presenter: data, source: 'search'
      end

      def display_contributor_fields_in_search(options={})
        data ||= pass_model(options)
        render "shared/ubiquity/contributor/show", presenter: data, source: 'search'
      end

      def display_editor_fields_in_search(options={})
        data ||= pass_model(options)
        render "shared/ubiquity/editor/show", presenter: data, source: 'search'
      end

      private
      def pass_model(options)
        my_model = options[:document].hydra_model.to_s
        my_id = options[:document].id
        presento ||= Ubiquity::SolrModelWrapper.new(my_model, my_id)
      end
  end
end
