# Generated via
#  `rails generate hyrax:work BookChapter`
module Hyrax
  class BookChapterForm < BookContributionForm

    self.model_class = ::BookChapter

    self.required_fields += %i[org_unit pagination publisher]
    self.remove_required_from_primary += %i[org_unit pagination publisher]

    self.terms = %i[title alt_title resource_type creator institution contributor abstract
                     date_published book_title pagination volume publisher issn rights_holder license
                     org_unit doi keyword refereed add_info
                    ]
  end
end
