module Hyrax
  class AdditionalCitationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    ## INHERIT @presenter?!!

    private

      helper_method :doi
      def doi
        @doi = doi(@presenter)
      end

      helper_method :isbn
      def isbn
        @isbn = isbn(@presenter)
      end
  end
end
