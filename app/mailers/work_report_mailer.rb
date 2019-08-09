class WorkReportMailer < ApplicationMailer
  default from: ENV['SETTINGS__CONTACT_EMAIL']

  def send_report(email, current_cname, email_type)
    @cname = current_cname
    @period = fetch_subject_based_on(email_type)
    @email_type = email_type
    @data = Ubiquity::ReportMailer.new.fetch_data_by_period(email_type)
    @summary_data = Ubiquity::ReportMailer.new.fetch_all_data_until_today
    @resource_type_hash = load_resource_type_yaml
    mail(to: email, subject: "Activity report for #{@cname} for #{@period}")
  end

  private

    def load_resource_type_yaml
      resource_type = YAML.load_file('config/authorities/resource_types.yml')
      resource_type['terms'].each_with_object({}) { |ele, hash| hash[ele['id']] = ele['term'] }
    end

    def fetch_subject_based_on(email_type)
      case email_type
      when 'weekly_email_list'
        "#{Time.zone.today - 7.days} to #{Time.zone.today}"
      when 'monthly_email_list'
        "#{Time.zone.today - 1.month} to #{Time.zone.today}"
      else
        "#{Time.zone.today - 1.year} to #{Time.zone.today}"
      end
    end
end
