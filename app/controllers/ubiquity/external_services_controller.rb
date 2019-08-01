class Ubiquity::ExternalServicesController < ApplicationController

  def generate_doi
   datacite_prefix = helpers.get_tenant_settings_hash(request.original_url)["datacite_prefix"]
   doi = Ubiquity::DoiService.new(external_service_params, datacite_prefix)
   doi_suffix = doi.suffix_generator
   render json: {"draft_doi": doi_suffix.draft_doi}
  end

  private

  def external_service_params
    params.require(:external_service).permit(:draft_doi, :work_id, :tenant_name, :work_model_name)
  end


end
