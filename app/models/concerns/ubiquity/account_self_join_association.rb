module Ubiquity
  module AccountSelfJoinAssociation
    extend ActiveSupport::Concern

    included do

      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings, :contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
                     :index_record_to_shared_search

      after_initialize :set_index_to_shared_search_for_live_sites, :set_index_to_shared_search_for_demo_sites

    end

    def get_site
      Site.instance
    end

    def get_content_block
      ContentBlock.all
    end

    private

    def set_index_to_shared_search_for_live_sites
      if cname.present? && !cname.include?('demo')
        self.settings['index_record_to_shared_search'] = 'true' if settings['index_record_to_shared_search'].blank?
      end
    end

    def set_index_to_shared_search_for_demo_sites
      if cname.present? && 'demo'.in?(self.cname)
        self.settings['index_record_to_shared_search'] = 'false' if settings['index_record_to_shared_search'].blank?
      end
    end

  end
end
