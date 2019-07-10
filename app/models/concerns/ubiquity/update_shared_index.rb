module Ubiquity
  module UpdateSharedIndex
    extend ActiveSupport::Concern

    included do
      #adds a work or file to shared index.
      after_save :add_record_to_index, on: [:create, :update]

      #removes a work or a file from shared_search
      before_destroy :remove_record_from_index

      #adds the file_sets in a work to shared_search index after a work has saved
      after_save :index_file_sets_in_work,  on: [:create, :update]

      #get all the the filesets in a work before the work is destroyed
      before_destroy :get_fileset_ids
      #remove the files in get_fileset_ids from shared_search index
      after_destroy :remove_file_sets_in_work_from_index

      #get the works in a collection, for subsequest removel from or addition into shared_search index
      before_save :get_collection_child_records
      before_destroy :get_collection_child_records

      after_save :reindex_members_after_collection_update
      after_destroy :reindex_members_to_remove_deleted_collection
    end

    private

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

    def add_record_to_index
      shared_search_check =  get_account_tenant && get_account_tenant.settings['include_in_shared_search']
      if parent_tenant.present? && shared_search_check == 'true'
        puts "adding record to shared-search #{self.class} - title is #{self.try(:title)} - with id #{self.id}"
        Ubiquity::SharedIndexSolrServiceWrapper.new(self.to_solr, 'add', parent_tenant, shared_search_check).update
        #if you switch the tenant back to the one that owns the work, you will get a blacklight error rendering show
        AccountElevator.switch!(self.account_cname)
      end
    end

    def remove_record_from_index
      if parent_tenant.present?
          puts "removing record from shared-search #{self.class} - title is #{self.try(:title)} - with id #{self.id}"
          Ubiquity::SharedIndexSolrServiceWrapper.new(self.id, 'remove', parent_tenant).update
          AccountElevator.switch!(self.account_cname)
      end
    end

    def index_file_sets_in_work
      shared_search_check =  get_account_tenant && get_account_tenant.settings['include_in_shared_search']
      if self.class != FileSet && self.try(:file_sets).present? && parent_tenant.present? && shared_search_check == 'true'
        file_sets_solr = self.file_sets.map(&:to_solr)
        puts "adding work fileset_ids to shared-search #{self.class} - title is #{self.try(:title)} - with id #{self.id}"
        Ubiquity::SharedIndexSolrServiceWrapper.new(file_sets_solr, 'add', parent_tenant, shared_search_check).update
        AccountElevator.switch!(self.account_cname)
      end
    end

    def get_fileset_ids
      if self.class != FileSet && self.try(:file_sets).present?
        self.file_sets.map(&:id)
      end
    end

    def remove_file_sets_in_work_from_index
      if get_fileset_ids.present? && parent_tenant.present?
        puts "removing work fileset_ids to shared-search #{self.class} - title is #{self.try(:title)} - with id #{self.id}"
        Ubiquity::SharedIndexSolrServiceWrapper.new(get_fileset_ids, 'remove', parent_tenant).update
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
