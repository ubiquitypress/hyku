# Preview all emails at http://localhost:3000/rails/mailers/work_report_mailer
class WorkReportMailerPreview < ActionMailer::Preview

  def send_report
    email = ENV['SMTP_USERNAME']
    tenant = ENV['DEVELOPER_PREVIEW_EMAIL_HOST_NAME']
    if email.present? && tenant.present?
      WorkReportMailer.send_report(email, tenant, 'weekly_email_list')
    end
  end

end
