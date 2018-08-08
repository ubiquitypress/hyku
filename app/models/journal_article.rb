# Generated via
#  `rails generate hyrax:work JournalArticle`
class JournalArticle < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::BasicMetadataDecorator
  include SharedMetadata

  self.indexer = JournalArticleIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Journal Article'

  property :issue, predicate: ::RDF::Vocab::Bibframe.term(:Serial), multiple: false do |index|
    index.as :stored_searchable
  end
  property :journal_title, predicate: ::RDF::Vocab::BIBO.Journal do |index|
    index.as :stored_searchable, :facetable
  end
  property :article_num, predicate: ::RDF::Vocab::BIBO.number, multiple: false do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
