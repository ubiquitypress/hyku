module Ubiquity
  module UserShowConcern
    extend ActiveSupport::Concern

    included do
      before_action :ensure_admin!
    end
    
  end
end
