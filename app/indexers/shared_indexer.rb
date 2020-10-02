class SharedIndexer < Hyrax::WorkIndexer
  # Use thumbnails served by RIIIF
  self.thumbnail_path_service = IIIFWorkThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('contributor_list', :stored_searchable)] = Ubiquity::ParseJson.new(object.contributor.first).fetch_value_based_on_key('contributor')
      solr_doc['date_published_si'] = Ubiquity::ParseDate.return_date_part(object.date_published, 'year')
      solr_doc[Solrizer.solr_name('all_orcid_isni', :stored_searchable)] = Ubiquity::FetchAllOrcidIsni.new(object).fetch_data
      # solr_doc[Solrizer.solr_name('work_tenant_url', :stored_searchable)] = Ubiquity::FetchTenantUrl.new(object).process_url
      # Following values were showing in OAI when the value is blank, Added a new field to display if the valuse is present
      solr_doc[Solrizer.solr_name('abstract_oai', :stored_searchable)] = object.abstract.presence
      solr_doc[Solrizer.solr_name('official_link_oai', :stored_searchable)] = object.official_link.presence
      solr_doc[Solrizer.solr_name('doi_oai', :stored_searchable)] = object.doi.presence
    end
  end
end
