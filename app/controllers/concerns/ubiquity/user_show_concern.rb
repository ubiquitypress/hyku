module Ubiquity
  module UserShowConcern
    extend ActiveSupport::Concern

    included do
      before_action :ensure_admin!
    end
    private

    def ensure_admin!
      authorize! :read, :admin_dashboard
    end
    
  end
end
