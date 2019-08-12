class WorkReportMailer < ApplicationMailer
  default from: ENV['SETTINGS__CONTACT_EMAIL']

  def send_report(email, current_cname, email_type)
    @cname = current_cname
    @period = fetch_subject_based_on(email_type)
    @email_type = email_type
    date_period = fetch_date_by(email_type)
    @data = fetch_data(date_period)
    @summary_data = fetch_data('[* TO *]')
    @resource_type_hash = load_resource_type_yaml
    mail(to: email, subject: "Activity report for #{@cname} for #{@period}")
  end

  private

    def fetch_data(date_range)
      query_data = ActiveFedora::SolrService.query(
        "system_create_dtsi: #{date_range}",
        {
          fl: ['resource_type_tesim, human_readable_type_tesim, file_set_ids_ssim, hasEmbargo_ssim, hasLease_ssim, visibility_ssi, lease_history_ssim, embargo_history_ssim'],
          fq: ['{!terms f=has_model_ssim}Article,Book,BookContribution,ConferenceItem,Dataset,ExhibitionItem,Image,Report,ThesisOrDissertation,TimeBasedMedia,GenericWork'],
          rows: 100_000_000
        }
      )
      sorted_array = query_data.sort_by{ |e| [e["human_readable_type_tesim"]] }.group_by { |e| e["human_readable_type_tesim"] }.to_h.values.flatten
      Ubiquity::FetchMailerReportData.new(sorted_array).generate_report
    end

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
