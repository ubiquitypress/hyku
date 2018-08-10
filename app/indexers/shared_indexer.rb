class SharedIndexer < Hyrax::WorkIndexer
  # Use thumbnails served by RIIIF
  self.thumbnail_path_service = IIIFWorkThumbnailPathService
end
