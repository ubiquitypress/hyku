# Preview all emails at http://localhost:3000/rails/mailers/work_report_mailer
class WorkReportMailerPreview < ActionMailer::Preview

  def send_report
    WorkReportMailer.send_report('ashikajith@gmail.com', 'ashik.localhost', 'weekly_email_list').deliver_now
  end

end
