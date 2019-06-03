module Ubiquity::WorkShowActionsHelper

  def delete_pop_up_message(presenter)
     official_link = presenter.solr_document["official_link_tesim"]
     if official_link.present? == true
       link_to "Delete", [main_app, presenter], class: 'btn btn-danger', data: { confirm: "Warning: This #{presenter.human_readable_type} has a live DOI. Deleting the work will cause the DOI to lead to a non-existent page." }, method: :delete
     else
       link_to "Delete", [main_app, presenter], class: 'btn btn-danger', data: { confirm: "Delete this #{presenter.human_readable_type}?" }, method: :delete
     end
  end

end
