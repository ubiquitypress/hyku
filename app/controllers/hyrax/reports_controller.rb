# Generated via
#  `rails generate hyrax:work Report`

module Hyrax
  class ReportsController < SharedBehaviorsController
    self.curation_concern_type = ::Report

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::ReportPresenter
    #
    # Instead we include IIIFManifest which uses the manifest-enabled show
    # presenter
    include Hyku::IIIFManifest
  end
end
