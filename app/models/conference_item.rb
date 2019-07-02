class ConferenceItem < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Ubiquity::BasicMetadataDecorator
  include Ubiquity::SharedMetadata
  include Ubiquity::AllModelsVirtualFields
  include Ubiquity::EditorMetadataModelConcern
  include Ubiquity::UpdateSharedIndex
  #include Ubiquity::MultipleModules

  self.indexer = ConferenceItemIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Conference Item'

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
