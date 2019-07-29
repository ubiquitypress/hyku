class ApplicationMailer < ActionMailer::Base
  helper Ubiquity::WorkReportMailerHelper
  layout 'mailer'
end
