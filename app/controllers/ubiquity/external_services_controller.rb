class Ubiquity::ExternalServicesController < ApplicationController

  def generate_doi
   account_record = JSON.parse(params['account_id'])
   doi = Ubiquity::DoiService.new(account_record['cname'], account_record['id'])
   doi_suffix = doi.suffix_generator
   render json: {"draft_doi": doi_suffix.draft_doi}
  end

  private

  def external_service_params
    params.require(:external_service).permit(:draft_doi, :work_id, :account_id)
  end


end
