
module Ubiquity
  module HyraxMyControllerOverride
    extend ActiveSupport::Concern

    Hyrax::MyController.instance_eval do
      def  configure_facets
        # clear facet's copied from the CatalogController
        blacklight_config.facet_fields = {}
        configure_blacklight do |config|
         # TODO: add a visibility facet (requires visibility to be indexed)
         config.add_facet_field ::Hyrax::IndexesWorkflow.suppressed_field, helper_method: :suppressed_to_status
         #config.add_facet_field solr_name("admin_set", :facetable), limit: 5
         config.add_facet_field solr_name("collection_names", :facetable), limit: 5, label: 'Collections'
         config.add_facet_field solr_name("resource_type", :facetable), limit: 5
        end

      end
      configure_facets

    end

  end
end
