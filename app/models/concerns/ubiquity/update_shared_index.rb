module Ubiquity
  module UpdateSharedIndex
    extend ActiveSupport::Concern

    included do
      after_save :add_record_to_index, on: [:create, :update]
      after_save :get_file_sets, on: [:create, :update]

      before_destroy :remove_record_from_index

      before_save :get_collection_child_records
      before_destroy :get_collection_child_records

      after_save :reindex_members_after_collection_update
      after_destroy :reindex_members_to_remove_deleted_collection
    end

    private

    def add_record_to_index
      shared_search_check =  get_account_tenant && get_account_tenant.settings['include_in_shared_search']
      if parent_tenant.present? && shared_search_check == 'true'
        Ubiquity::SharedIndexSolrServiceWrapper.new(self.to_solr, 'add', parent_tenant, shared_search_check).update
        #if you switch the tenant back to the one that owns the work, you will get a blacklight error rendering show
        AccountElevator.switch!(self.account_cname)
      end
    end

    def remove_record_from_index
      if parent_tenant.present?
          Ubiquity::SharedIndexSolrServiceWrapper.new(self.to_solr, 'remove', parent_tenant).update
          AccountElevator.switch!(self.account_cname)
      end
    end

    def get_account_tenant
      if self.account_cname.present?
        @account ||=  Account.where(cname: self.account_cname).first
      end
    end

    def parent_tenant
      account =  get_account_tenant
      if account.present? && account.parent.present?
        parent = account.parent
        parent.cname
      end
    end

    def get_file_sets
      shared_search_check =  get_account_tenant && get_account_tenant.settings['include_in_shared_search']

      if self.class != FileSet && self.try(:file_sets).present? && parent_tenant.present? && shared_search_check == 'true'
        file_sets_solr =  self.file_sets.map(&:to_solr)
        Ubiquity::SharedIndexSolrServiceWrapper.new(file_sets_solr, 'add', parent_tenant, shared_search_check).update
        AccountElevator.switch!(self.account_cname)
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
