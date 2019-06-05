# Generated via
#  `rails generate hyrax:work Exhibition`

module Hyrax
  class ExhibitionsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Exhibition

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ExhibitionPresenter
  end
end
