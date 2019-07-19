module Ubiquity
  module UpdateSharedIndex
    extend ActiveSupport::Concern

    included do
      after_save :add_record_to_index, on: [:create, :update]

      #get all the the filesets in a work before the work is destroyed
      before_destroy :get_fileset_ids
      before_destroy :remove_record_from_index

      #remove the files in get_fileset_ids from shared_search index
      after_destroy :remove_file_sets_in_work_from_index

      before_save :get_collection_child_records
      before_destroy :get_collection_child_records

      after_save :reindex_members_after_collection_update
      after_destroy :reindex_members_to_remove_deleted_collection
    end

    private

    def add_record_to_index
      if parent_tenant.present? && !self.account_cname.include?('demo')
        AccountElevator.switch!(self.account_cname)
        Ubiquity::SharedIndexSolrServiceWrapper.new(self.to_solr, 'add', parent_tenant, get_file_sets).update
        #if you switch the tenant back to the one that owns the work, you will get a blacklight error rendering show
        AccountElevator.switch!(self.account_cname)
      end
    end

    def remove_record_from_index
      if parent_tenant.present? && !self.account_cname.include?('demo')
          puts "removing self.id from shared-search index"
          Ubiquity::SharedIndexSolrServiceWrapper.new(self.id, 'remove', parent_tenant).update
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
      if self.class != FileSet && self.try(:file_sets).present?
        self.file_sets.map do |file_set|
          file_set.to_solr
        end
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
