module Ubiquity
  module HyraxWorkFormOverride
    extend ActiveSupport::Concern

    included do
      delegate :account_cname, :collection_id, :collection_names, to: :model
    end

    def public_collections_for_select
      service = Hyrax::CollectionsService.new(@controller)
      Hyrax::CollectionOptionsPresenter.new(service).select_options(:read)
    end

    # Select collection(s) based on passed-in params and existing memberships.
    # @return [Array] a list of collection identifiers
    def non_fedora_association_collection_id(collection_ids)
      (collection_id + Array.wrap(collection_ids)).uniq.compact
    end

    # Fields that are automatically drawn on the page below the fold
    def secondary_terms
      terms - primary_terms -
          [:files, :visibility_during_embargo, :embargo_release_date,
           :visibility_after_embargo, :visibility_during_lease,
           :lease_expiration_date, :visibility_after_lease, :visibility,
           :thumbnail_id, :representative_id, :ordered_member_ids,
           :member_of_collection_ids, :in_works_ids, :admin_set_id,
           :collection_id, :collection_names]
    end

  end
end
