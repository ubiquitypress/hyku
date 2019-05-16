module Hyrax
  class GenericWorksController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = GenericWork
  end

end
