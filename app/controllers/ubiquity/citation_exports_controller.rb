module Ubiquity
  class CitationExportsController < ApplicationController
    include Ubiquity::CitationsExportConcern

    def export_to_rif
      work = ActiveFedora::Base.find(params[:work_id])
      export_data = fetch_data work
      filename = "#{params[:work_id]}-citations.ris"
      send_data(export_data.join("\n"), type: "application/x-endnote-refer", filename: filename)
    end
  end
end
