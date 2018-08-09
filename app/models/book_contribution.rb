# Generated via
#  `rails generate hyrax:work BookContribution`
class BookContribution < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::BasicMetadataDecorator
  include SharedMetadata

  self.indexer = BookContributionIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Book Contribution'

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
