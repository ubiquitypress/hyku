module Ubiquity
  module AccountSelfJoinAssociation
    extend ActiveSupport::Concern

    included do

      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings, :contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
                                :include_in_shared_search

      after_initialize :set_include_in_shared_search_for_live_sites, :set_include_in_shared_search_for_demo_sites

    end

    private

    def set_include_in_shared_search_for_live_sites
      if cname.present? && !cname.include?('demo')
        self.settings['include_in_shared_search'] = 'true' if settings['include_in_shared_search'].blank?
      end
    end

    def set_include_in_shared_search_for_demo_sites
      if cname.present? && 'demo'.in?(self.cname)
        self.settings['include_in_shared_search'] = 'false' if settings['include_in_shared_search'].blank?
      end
    end

  end
end
