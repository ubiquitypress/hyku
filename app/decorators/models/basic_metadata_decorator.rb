module Hyrax
  module BasicMetadataDecorator
    extend ActiveSupport::Concern
    # include here properties (fields) shared across all templates
    # also see SharedMetadata
    included do
      property :institution, predicate: ::RDF::Vocab::ORG.organization do |index|
        index.as :stored_searchable
      end
      property :org_unit, predicate: ::RDF::Vocab::ORG.OrganizationalUnit do |index|
        index.as :stored_searchable
      end
      property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed") do |index|
        index.as :stored_searchable
      end
      property :funder, predicate: ::RDF::Vocab::MARCRelators.fnd do |index|
        index.as :stored_searchable
      end
      property :fndr_project_ref, predicate: ::RDF::Vocab::BF2.awards do |index|
        index.as :stored_searchable
      end
      property :add_info, predicate: ::RDF::Vocab::BIBO.term(:Note), multiple: false do |index|
        index.as :stored_searchable
      end
      property :date_published, predicate: ::RDF::Vocab::DC.available, multiple: false do |index|
        index.as :stored_searchable
      end
      property :date_accepted, predicate: ::RDF::Vocab::DC.dateAccepted, multiple: false do |index|
        index.as :stored_searchable
      end
      property :date_submitted, predicate: ::RDF::Vocab::DC.dateSubmitted, multiple: false do |index|
        index.as :stored_searchable
      end
      property :project_name, predicate: ::RDF::Vocab::BF2.term(:CollectiveTitle), multiple: false do |index|
        index.as :stored_searchable
      end
      property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder, multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end
