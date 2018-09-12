module Hyrax

  class ArticlesController < SharedBehaviorsController

    self.curation_concern_type = ::Article

  end
end
