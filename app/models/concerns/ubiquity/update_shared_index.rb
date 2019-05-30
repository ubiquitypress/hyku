module Ubiquity
  module UpdateSharedIndex
    extend ActiveSupport::Concern

    included do
      after_save :add_record_to_index, on: [:create, :update]
      before_destroy :remove_record_from_index

      before_save :get_collection_child_records
      before_destroy :get_collection_child_records

      after_save :reindex_members_after_collection_update
      after_destroy :reindex_members_to_remove_deleted_collection
      attr_accessor :works_in_collection
    end

    private

    def add_record_to_index
      if parent_tenant.present? && !self.account_cname.include?('demo')
        Ubiquity::SharedIndexSolrServiceWrapper.new(self.to_solr, 'add', parent_tenant, get_file_sets).update

        #if you switch the tenant back to the one that owns the work, you will get a blacklight error rendering show
        AccountElevator.switch!(self.account_cname)
      end
    end

    def remove_record_from_index
      if parent_tenant.present? && !self.account_cname.include?('demo')
          Ubiquity::SharedIndexSolrServiceWrapper.new(self.to_solr, 'remove', parent_tenant).update
          AccountElevator.switch!(self.account_cname)
      end
    end

    def parent_tenant
      account = Account.where(cname: self.account_cname).first
      if account.present? && account.parent.present?
        parent = account.parent
        parent.cname
      end
    end

    def get_file_sets
      if self.try(:thumbnail).present?
        self.thumbnail.to_solr
      end
    end

    def get_collection_child_records
      if self.class == Collection
        #get works in this collection
        self.try(:member_objects)
      end
    end

    def reindex_members_to_remove_deleted_collection
      if self.class == Collection && get_collection_child_records.present?
        get_collection_child_records.each do |work|
          work.member_of_collections.clear
          work.save
        end
      end
    end

    def reindex_members_after_collection_update
      if self.class == Collection && get_collection_child_records.present?
        get_collection_child_records.each do |work|
          work.save
        end
      end
    end

  end
end
