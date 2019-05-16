module Ubiquity
  module UpdateSharedIndex
    extend ActiveSupport::Concern

    included do
      after_save :add_work, on: [:create, :update]
      before_destroy :remove_work
    end

    private

    def add_work
      if parent_tenant.present? && !self.account_cname.include?('demo')
        Ubiquity::SharedIndexSolrServiceWrapper.new(self.to_solr, 'add', parent_tenant, get_file_sets).update

        #if you switch the tenant back to the one that owns the work, you will get a blacklight error rendering show
        AccountElevator.switch!(self.account_cname)
      end
    end

    def remove_work
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
      if self.try(:file_sets).present?
        self.file_sets
      end
    end

  end
end
