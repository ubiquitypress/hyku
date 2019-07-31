module Ubiquity
#This module was created by Ubiquity to set the file_avialabiliy to allow for faceting. The status will change according to the business rule below:
#  A: File available from this repository, B: External link (access may be restricted), C: File not available

#public files attached, official URL present, 'mint:register' or 'mint:findable' = A
#public files attached, no official URL present, no 'mint:register' or 'mint:findable' = A
#public files attached, no official URL present, 'mint:register' or 'mint:findable' = A
#public files attached, official URL present, no 'mint:register' or 'mint:findable' = A, B
#no public files attached, official URL present, no 'mint:register' or 'mint:findable' = B
#no public files attached, official URL present, 'mint:register' or 'mint:findable' = C
#no public files attached, no official URL present, 'mint:register' or 'mint:findable' = C
#no public files attached, no official URL present, no 'mint:register' or 'mint:findable' = C

  module FileAvailabilityFaceting
    extend ActiveSupport::Concern

    included do
      before_save :set_file_availability_for_faceting
    end

    private

    def set_file_availability_for_faceting
      if ('open'.in? get_work_filesets_visibility)  && self.official_link.present? && (doi_option_value_check? == true)

        self.file_availability = ['File available from this repository']

      elsif ('open'.in? get_work_filesets_visibility) && self.official_link.blank?  && (doi_option_value_check? == false)

        self.file_availability = ['File available from this repository']

      elsif ('open'.in? get_work_filesets_visibility) && self.official_link.present? && (doi_option_value_check? == false)

        multiple_values

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] } || get_work_filesets_visibility.blank? ) && self.official_link.present? && (doi_option_value_check? == false)

        self.file_availability =  ["External link (access may be restricted)"]

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] } || get_work_filesets_visibility.blank?) && !self.official_link.present? && (doi_option_value_check? == true)

        self.file_availability = ['File not available']

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] } || get_work_filesets_visibility.blank?) && self.official_link.present? && (doi_option_value_check? == true)

        self.file_availability = ['File not available']

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] } || get_work_filesets_visibility.blank?) && !self.official_link.present? && (doi_option_value_check? == false)
        
        self.file_availability = ['File not available']
      end
    end

    def doi_option_value_check?
      self.doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable"]
    end

    def multiple_values
      if self.file_availability.include? "File not available"
        self.file_availability.delete "File not available"
        self.file_availability = self.file_availability | ['External link (access may be restricted)', 'File available from this repository']
      else
        self.file_availability = self.file_availability | ['External link (access may be restricted)', 'File available from this repository']
      end
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
