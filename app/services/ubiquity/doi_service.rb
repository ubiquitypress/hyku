module Ubiquity
  class DoiService

    def suffix_generator
      suffix = draft_doi_hash[:draft_doi].split('/').last.to_i
      suffix =+ 1
    end

    def draft_doi_hash
      draft_doi_array = [{draft_doi: '10.12.1/1'},  {draft_doi: '10.12.1/2'},  {draft_doi: '10.12.1/3'}]
      sorted_values = draft_doi_array.max_by {|hash| hash[:draft_doi].split('/').last.to_i}
    end

  end
end
