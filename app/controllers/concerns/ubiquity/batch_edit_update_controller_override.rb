module Ubiquity
  module BatchEditUpdateControllerOverride
    include ActiveSupport::Concern

    def work_params
      work_params = params[form_class.model_name.param_key]
      work_params[:date_published] = Ubiquity::ParseDate.transform_published_date_group(work_params[:date_published_group]) if work_params.present?
      form_class.model_attributes(work_params)
    end

  end
end
