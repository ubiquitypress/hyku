class CollectionIndexer < Hyrax::CollectionIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Use thumbnails served by RIIIF
  self.thumbnail_path_service = IIIFCollectionThumbnailPathService

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('work_tenant_url', :stored_searchable)] = Ubiquity::FetchTenantUrl.new(object).process_url
    end
  end
end
