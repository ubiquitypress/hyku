module Ubiquity
  module BatchEditUpdateControllerOverride
    include ActiveSupport::Concern

    def work_params
      work_params = params[form_class.model_name.param_key] || ActionController::Parameters.new
      work_params[:date_published] = transform_date_group(work_params) if work_params.present?
      form_class.model_attributes(work_params)
    end

    private
      def transform_date_group(work_params)
        # check the year field: `hash.first` returns the year key, for example: ["date_published_year", "2002"]
        hash = work_params[:date_published_group] || {}
        if hash.present?
          date = ''
          hash.each do |date_hash|
            date << date_hash[:date_published_year] if date_hash[:date_published_year].present?
            date << '-' + date_hash[:date_published_month] if date_hash[:date_published_month].present?
            date << '-' + date_hash[:date_published_day] if date_hash[:date_published_day].present?
          end
          date
        end
      end
  end
end