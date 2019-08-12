class WorkReportMailer < ApplicationMailer
  default from: ENV['SETTINGS__CONTACT_EMAIL']

  def send_report(email, current_cname, email_type)
    @cname = current_cname
    @period = fetch_subject_based_on(email_type)
    @email_type = email_type
    date_period = fetch_date_by(email_type)
    @data = Ubiquity::FetchMailerReportData.fetch_data(date_period)
    @summary_data = Ubiquity::FetchMailerReportData.fetch_data('[* TO *]')
    @resource_type_hash = load_resource_type_yaml
    mail(to: email, subject: "Activity report for #{@cname} for #{@period}")
  end

  private

    def load_resource_type_yaml
      resource_type = YAML.load_file('config/authorities/resource_types.yml')
      resource_type['terms'].each_with_object({}) { |ele, hash| hash[ele['id']] = ele['term'] }
    end

    def fetch_date_by(email_type)
      case email_type
      when 'weekly_email_list'
        '[NOW-7DAY/DAY TO NOW]'
      when 'monthly_email_list'
        '[NOW-1MONTH/MONTH TO NOW]'
      when 'yearly_email_list'
        '[NOW-1YEAR/YEAR TO NOW]'
      else
        '[* TO *]'
      end
    end

    def fetch_subject_based_on(email_type)
      case email_type
      when 'weekly_email_list'
        "#{Time.zone.today - 7.days} to #{Time.zone.today}"
      when 'monthly_email_list'
        "#{Time.zone.today - 1.month} to #{Time.zone.today}"
      when 'yearly_email_list'
        "#{Time.zone.today - 1.year} to #{Time.zone.today}"
      end
    end
end
