module Hyku
  class FileSetPresenter < Hyrax::FileSetPresenter
    include DisplaysImage
    # CurationConcern methods
    delegate :rendering_ids, :license, to: :solr_document
  end
end
