module Ubiquity
  class FetchMailerReportData

    def initialize(sorted_array)
      @sorted_array = sorted_array
    end

    def self.fetch_data(date_range)
      query_data = ActiveFedora::SolrService.query(
        "system_create_dtsi: #{date_range}",
        {
          fl: ['resource_type_tesim, human_readable_type_tesim, file_set_ids_ssim, hasEmbargo_ssim, hasLease_ssim, visibility_ssi, lease_history_ssim, embargo_history_ssim'],
          fq: ['{!terms f=has_model_ssim}Article,Book,BookContribution,ConferenceItem,Dataset,ExhibitionItem,Image,Report,ThesisOrDissertation,TimeBasedMedia,GenericWork'],
          rows: 100_000_000
        }
      )
      sorted_array = query_data.sort_by{ |e| [e["human_readable_type_tesim"]] }.group_by { |e| e["human_readable_type_tesim"] }.to_h.values.flatten
      new(sorted_array).generate_report
    end

    def generate_report
      final_hash = {}
      @sorted_array.group_by { |e| e['resource_type_tesim'] }.each do |key, value|
        work_with_file_count, work_without_file_count = 0, 0
        public_records, private_records, embargo, lease = 0,0,0,0
        institute_records, new_files_added = 0, 0
        sample_hash = {}
        value.each do |record_hash|
          sample_hash[:work_type] = record_hash['human_readable_type_tesim'].try(:first)
          sample_hash[:resource_type] = record_hash['resource_type_tesim'].try(:first)
          if record_hash['hasLease_ssim'].present? && record_hash['lease_history_ssim'].blank?
            lease += 1
          elsif record_hash['hasEmbargo_ssim'].present? && record_hash['embargo_history_ssim'].blank?
            embargo += 1
          elsif record_hash['visibility_ssi'] == 'authenticated'
            institute_records += 1
          elsif record_hash['visibility_ssi'] == 'open'
            public_records += 1
          else
            private_records += 1
          end
          if record_hash['file_set_ids_ssim'].present?
            new_files_added += record_hash['file_set_ids_ssim'].count
            work_with_file_count += 1
          else
            work_without_file_count += 1
          end
        end
        final_hash[key.try(:first).to_s] = sample_hash.merge(work_with_file_count: work_with_file_count, work_without_file_count: work_without_file_count,
                                                  new_files_added: new_files_added, embargo: embargo, lease: lease,
                                                  public_records: public_records, private_records: private_records, institute_records: institute_records)
      end
      final_hash
    end

  end
end
