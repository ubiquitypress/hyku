module Ubiquity
  module HyraxWorkFormOverride
    extend ActiveSupport::Concern

    def public_collections_for_select
      service = Hyrax::CollectionsService.new(@controller)
      Hyrax::CollectionOptionsPresenter.new(service).select_options(:read)
    end

  end
end
