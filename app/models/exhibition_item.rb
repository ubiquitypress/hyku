# Generated via
#  `rails generate hyrax:work ExhibitionItem`
class ExhibitionItem < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include HasRendering
  include Ubiquity::SharedMetadata
  include Ubiquity::BasicMetadataDecorator
  include Ubiquity::AllModelsVirtualFields
  include Ubiquity::EditorMetadataModelConcern
  include Ubiquity::VersionMetadataModelConcern
  include Ubiquity::UpdateSharedIndex
  include Ubiquity::FileAvailabilityFaceting
  include ::Ubiquity::CachingSingle
  include ::Ubiquity::WorkTypeValidator

  self.indexer = ExhibitionItemIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Exhibition Item'

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
