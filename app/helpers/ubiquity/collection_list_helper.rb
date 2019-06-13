module Ubiquity
  module CollectionListHelper
    def collection_child_row_details(document)
      html_elemt = "
      <dt class='col-lg-2' style='width:13%;'>Date Uploaded:</dt>
      <dd class='col-lg-2'> #{document.date_uploaded }</dd></dl>"
      if document.keyword.present?
        html_elemt += "<dt class='col-lg-1'>Keywords:</dt> <dd class='col-lg-4'>#{document.keyword.join(';')}</dd>"
      end
      html_elemt
    end
  end
end
