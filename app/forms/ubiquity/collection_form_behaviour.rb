module Ubiquity
  module CollectionFormBehaviour
    # Terms that appear within the accordion
    def secondary_terms
      %i[creator
         contributor
         description
         keyword
         license
         publisher
         date_created
         language
         identifier
         based_near
         related_url
         resource_type]
    end
  end
end
