module Admin
  class ExportsController < AdminController
    layout 'dashboard'
    def index
    end

    def export_database
      csv_generator = Ubiquity::Exporter::CsvGenerator.new(request.original_url)
      data = csv_generator.export_database_as_remapped_data
      respond_to do |format|
        format.csv { send_data data, filename: "#{current_account.cname}_metadata.csv" }
      end
    end

    def export_remap_model
      model = params['model']
      #example of exporting jist a single model class eg dataset
      data = Ubiquity::Exporter::CsvGenerator.new(request.original_url).export_remap_model(model)
      respond_to do |format|
        format.csv { send_data data, filename: "#{current_account.cname}_#{model}_metadata.csv" }
      end
    end

    def export_model
      data = Ubiquity::Exporter::CsvGenerator.new(request.original_url).regular_export
      respond_to do |format|
        format.csv {render plain: data, content_type: 'text/plain'}
      end
    end

    def send_mail_report
      emails = process_email
      emails.each do |email|
        WorkReportMailer.send_report(email.strip, current_account.cname, params[:email_type]).deliver_later
      end
      redirect_to hyrax.admin_stats_path(anchor: 'email_reports')
    end

    private

    def allowed_params
      params.permit(:model, :locale)
    end

    def process_email
      current_account.settings[params[:email_type]].first.split(';')
    end

  end
end
