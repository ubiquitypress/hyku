class FileSetIndexer < Hyrax::FileSetIndexer
  self.thumbnail_path_service = IIIFWorkThumbnailPathService
  def generate_solr_document

    super.tap do |solr_doc|
      solr_doc['hasFormat_ssim'] = object.rendering_ids
    end

  rescue Ldp::HttpError => exception
     puts "exception is: #{exception.inspect}"
     puts "calling to_solr on fileset failed #{object.inspect}"
     object 
  end
end
