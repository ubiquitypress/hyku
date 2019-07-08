class FileSetIndexer < Hyrax::FileSetIndexer
  self.thumbnail_path_service = IIIFWorkThumbnailPathService
  def generate_solr_document

    super.tap do |solr_doc|
      solr_doc['hasFormat_ssim'] = object.rendering_ids
    end

  rescue Ldp::HttpError => exception
     puts "exception is: #{exception.inspect}"
     puts "calling to_solr on fileset failed #{object.inspect}"

     #manually call generate_solr_document on the indexing_service. It returns
     # the same values as calling to_solr on a file_set object
     get_solr_attributes = ActiveFedora::IndexingService.new(object).generate_solr_document
     puts "get_solr_attributes #{get_solr_attributes.inspect}"
     get_solr_attributes
  end

end
