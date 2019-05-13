module Hyrax

  class ArticlesController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::Article

  end
end
