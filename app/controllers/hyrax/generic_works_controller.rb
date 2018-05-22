module Hyrax
  class GenericWorksController < SharedController
    self.curation_concern_type = GenericWork

    include Hyku::IIIFManifest
  end
end
