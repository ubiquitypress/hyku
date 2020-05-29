module Admin
  class ExportsController < AdminController
    layout 'dashboard'
    before_action :s3_wrapper, only: [:index, :s3_link_redirect]
    def index
      @s3_objects = @s3_wrapper.all_objects_in_s3bucket.presence || []
    end

    def export_database
      model = params['model']
      UbiquityExporterJob.perform_later(current_account.cname, model, current_user.id)
      redirect_to  admin_exports_path,  notice: "We are generating the CSV and you will see a notification at the top right hand side of this app when it is ready"
    end

    def export_remap_model
      model = params['model']
      UbiquityExporterJob.perform_later(current_account.cname, model, current_user.id)
      redirect_to  admin_exports_path,  notice: "We are generating the CSV and you will see a notification at the top right hand side of this app when it is ready"
    end

    def export_model
      model = params['model']
      data = Ubiquity::CsvGenerator.regular_export
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

    def s3_link_redirect
      redirect_to   @s3_wrapper.download_url(params[:filename])
    end

    private

    def process_email
      current_account.settings[params[:email_type]].first.split(';')
    end

    def s3_wrapper
      @s3_wrapper = Ubiquity::S3Wrapper.new(bucket_name: ENV['S3_BUCKET_NAME'])
    end


  end
end
