module Ubiquity
#This module was created by Ubiquity to set the file_avialabiliy to allow for faceting. The status will change according to the business rule below:
#  A: File available from this repository, B: External link (access may be restricted), C: File not available

# public files attached, official URL present, draft DOI present = A
# public files attached, no official URL present, no draft DOI present = A
# public files attached, no official URL present, draft DOI present = A
# public files attached, official URL present, no draft DOI present = A, B
# no public files attached, official URL present, no draft DOI present = B
# no public files attached, official URL present, draft DOI present = C
# no public files attached, no official URL present, draft DOI present = C
# no public files attached, no official URL present, no draft DOI present = C
  module MultipleModules
    extend ActiveSupport::Concern

    included do
      before_save :set_file_availability_for_faceting
    end

    private

    def set_file_availability_for_faceting
      if self.present? && !self.official_link.present? && draft_doi_check? && ('open'.in? get_work_filesets_visibility)
        self.file_availability = ['File available from this repository']
      elsif self.present? && self.official_link.present? && draft_doi_check? && ('open'.in? get_work_filesets_visibility)
        self.file_availability = ['File available from this repository']
      elsif self.present? && !self.official_link.present? && !draft_doi_check? && ('open'.in? get_work_filesets_visibility)
        self.file_availability = ['File available from this repository']
      elsif self.present? && self.official_link.present? && !draft_doi_check? && ('open'.in? get_work_filesets_visibility)
        self.file_availability = self.file_availability | ["External link (access may be restricted)", 'File available from this repository']
      elsif self.present? && self.official_link.present? && !draft_doi_check? || (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] })
        self.file_availability = self.file_availability | ["External link (access may be restricted)"]
      elsif self.present? && !self.official_link.present? && draft_doi_check? || (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] })
        self.file_availability = ['File not available']
      elsif self.present? && !self.official_link.present? && !draft_doi_check? || (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] })
        self.file_availability = ['File not available']
      elsif self.present? && self.official_link.present? && draft_doi_check? || (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] })
        self.file_availability = ['File not available']
      end
    end

    def draft_doi_check?
      draft_doi_object = ExternalService.where(draft_doi: self.try(:draft_doi)).first
      return true if draft_doi_object.present?
      return false if draft_doi_object.blank?
    end


    def get_work_filesets_visibility
      if file_sets.present?
        work_visibility_array = file_sets.map(&:visibility)
      else
        []
      end
    end

  end
end
