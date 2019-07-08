class SharedIndexer < Hyrax::WorkIndexer
  # Use thumbnails served by RIIIF
  self.thumbnail_path_service = IIIFWorkThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['contributor_list_tesim'] = Ubiquity::ParseJson.new(object.contributor.first).fetch_value_based_on_key('contributor')
    end
  end
end
