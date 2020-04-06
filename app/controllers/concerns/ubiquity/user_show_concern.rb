module Ubiquity
  module UserShowConcern
    include ActiveSupport::Concern

    before_action :ensure_admin!
  end
end
