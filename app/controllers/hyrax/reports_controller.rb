# Generated via
#  `rails generate hyrax:work Report`

module Hyrax
  class ReportsController < SharedBehaviorsController
    skip_load_and_authorize_resource only: [:manifest, :show]
    self.curation_concern_type = ::Report

    # Use this line if you want to use a custom presenter
    # self.show_presenter = Hyrax::ReportPresenter
  end
end
