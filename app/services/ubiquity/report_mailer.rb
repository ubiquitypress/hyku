module Ubiquity
  class ReportMailer

    def fetch_data_by_period(email_type)
      date_period = fetch_date_by(email_type)
      fetch_data(date_period)
    end

    def fetch_all_data_until_today
      fetch_data('[* TO *]')
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
  end
end
