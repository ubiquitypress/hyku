# Preview all emails at http://localhost:3000/rails/mailers/work_report_mailer
class WorkReportMailerPreview < ActionMailer::Preview

  def weekly_report
    @data = fetch_data
    mail(to: 'ashik.ajith@ubiquitypress.com', subject: 'Weekly Report')
  end

  private

    def fetch_data
      query_data = ActiveFedora::SolrService.query(
        'system_create_dtsi: [NOW-7DAY/DAY TO NOW]',
        {
          fl: ['resource_type_tesim, human_readable_type_tesim, file_set_ids_ssim'],
          fq: ['{!terms f=has_model_ssim}Article,Book,BookContribution,ConferenceItem,Dataset,ExhibitionItem,Image,Report,ThesisOrDissertation,TimeBasedMedia,GenericWork'],
          rows: 100_000
        }
      )
      sorted_array = query_data.group_by { |e| e["human_readable_type_tesim"] }.sort.to_h.values.flatten
      generate_weekly_report(sorted_array)
    end

    def generate_weekly_report(sorted_array)
      sorted_array.group_by { |e| e['resource_type_tesim'] }.each do |key, value|
        work_with_file_count = 0
        work_without_file_count = 0
        sample_hash = {}
        value.each do |record_hash|
          sample_hash[:work_type] = record_hash['human_readable_type_tesim'].first
          sample_hash[:resource_type] = record_hash['resource_type_tesim'].first
          if record_hash['file_set_ids_ssim'].present?
            work_with_file_count += 1
          else
            work_without_file_count += 1
          end
        end
        final_hash[key.first] = sample_hash.merge(work_with_file_count: work_with_file_count, work_without_file_count: work_without_file_count )
      end
      final_hash
    end
end
