module Hyrax
  class GenericWorksController < AdditionalCitationsController
    self.curation_concern_type = GenericWork

    include Hyku::IIIFManifest
  end
end
