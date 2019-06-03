module Ubiquity
  module CollectionFormBehaviour
    Hyrax::Forms::CollectionForm.terms.push(:account_cname)
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
         account_cname
       ]
    end
  end
end
