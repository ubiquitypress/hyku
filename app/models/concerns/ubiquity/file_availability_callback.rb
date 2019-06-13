module Ubiquity
  module FileAvailabilityCallback
    extend ActiveSupport::Concern

    included do
      after_update :add_file_avalaibility
      #after_save :add_file_avalaibility
    end

    private

    def add_file_avalaibility
      if self.parent.present?
        work = self.parent
           puts"kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk#{work.inspect}"

        file_status = get_work_filesets_visibility(work.file_sets)
          puts"SPAIN==========#{file_status.inspect}"
        if file_status.present?
          puts"ITALY================="
          work.file_availability = [file_status]
          work.save
        end
      end
    end

    def get_work_filesets_visibility(file_sets)
      work_visibility_array = file_sets.map(&:visibility) # || official_link_check?
      puts "ARRAYYY#{work_visibility_array}"
      if 'open'.in? work_visibility_array
        puts"INDIA============="
       'available'
     elsif work_visibility_array.any? {|status| status.in? ['authenticated', 'restricted'] }
        puts"CANADA=============="
       'unavailable'
      end
    end

    def official_link_check?
      link = self.try(:parent).try(:official_link)
      if link.present?
        kk = ExeternalService.where(draft_doi: self.parent.draft_doi).first
        return true if kk.present?
        return false if kk.blank?
      end
    end
  end
end
