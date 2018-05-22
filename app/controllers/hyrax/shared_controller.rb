module Hyrax
  class SharedController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks

    def show
      super
      doi_regex = %r{10.\d{4,9}\/[-._;()\/:A-Z0-9]+}i
      isbn_regex = /(?:ISBN[- ]*13|ISBN[- ]*10|)\s*
                     ((?:(?:9[\s-]*7[\s-]*[89])?[ -]?(?:[0-9][ -]*){9})[ -]*(?:[0-9xX]))/x
      @doi = ""
      @isbn = []
      @presenter.identifier.each do |str|
        @doi = str.scan(doi_regex).join
        @isbn += str.scan(isbn_regex).flatten
      end
    end
  end
end
