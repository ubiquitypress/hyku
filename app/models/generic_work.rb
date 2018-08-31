class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include HasRendering
  include Ubiquity::SharedMetadata
  include Ubiquity::BasicMetadataDecorator
  include Ubiquity::AllModelsVirtualFields
  include Ubiquity::EditorMetadataModelConcern

  validates :title, presence: { message: 'Your work must have a title.' }

  # This indexer uses IIIF thumbnails:
  self.indexer = WorkIndexer
  self.human_readable_type = 'Work'

  include ::Hyrax::BasicMetadata

end
