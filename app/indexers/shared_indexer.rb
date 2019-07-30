class SharedIndexer < Hyrax::WorkIndexer
  # Use thumbnails served by RIIIF
  self.thumbnail_path_service = IIIFWorkThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('contributor_list', :stored_searchable)] = Ubiquity::ParseJson.new(object.contributor.first).fetch_value_based_on_key('contributor')
      solr_doc['date_published_si'] = Ubiquity::ParseDate.return_date_part(object.date_published, 'year')
      solr_doc[Solrizer.solr_name('all_orcid_isni', :stored_searchable)] = Ubiquity::FetchAllOrcidIsni.new(object).fetch_data
    end
  end
end
