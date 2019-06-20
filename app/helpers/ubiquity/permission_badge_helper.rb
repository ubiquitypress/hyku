
module Ubiquity
  module PermissionBadgeHelper
    def fetch_permission_badge(object)
      if object.embargo_release_date.present?
        'embargo'
      elsif object.lease_expiration_date
        'lease'
      else
        object.model.visibility
      end
    end
  end
end
