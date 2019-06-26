module Ubiquity
#This module was created by Ubiquity to set the file_avialabiliy to allow for faceting. The status will change according to the business rule below:
#  A: File available from this repository, B: External link (access may be restricted), C: File not available

# public files attached, official URL present, doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable" present = A
# public files attached, no official URL present, no doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable"present = A
# public files attached, no official URL present, doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable" present = A
# public files attached, official URL present, no doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable" present = A, B
# no public files attached, official URL present, no doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable" present = B
# no public files attached, official URL present, doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable" present = C
# no public files attached, no official URL present, doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable" present = C
# no public files attached, no official URL present, doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable" DOI present = C
  module MultipleModules
    extend ActiveSupport::Concern

    included do
      #before_save :set_file_availability_for_faceting
      after_save :set_file_availability_for_faceting
    end

    private

    def set_file_availability_for_faceting
      if ('open'.in? get_work_filesets_visibility)  && self.official_link.present? && (doi_option_value_check? == true)
        self.file_availability = ['File available from this repository']
          puts"LONDONN21"

      elsif ('open'.in? get_work_filesets_visibility) && !self.official_link.present? && (doi_option_value_check? == false)
        self.file_availability = ['File available from this repository']
          puts"MADRID22"

      elsif ('open'.in? get_work_filesets_visibility) && !self.official_link.present? && (doi_option_value_check? == true)
        self.file_availability = ['File available from this repository']
          puts"NAPOLI23"

      elsif ('open'.in? get_work_filesets_visibility) && self.official_link.present? && (doi_option_value_check? == false)
        #self.file_availability = self.file_availability | ["External link (access may be restricted)", 'File available from this repository']
        self.file_availability = ["External link (access may be restricted)", 'File available from this repository']

        puts"LONDONN24"

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] }) && self.official_link.present? && (doi_option_value_check? == false)
        self.file_availability =  ["External link (access may be restricted)"]
          puts"LONDONN25"

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] } || get_work_filesets_visibility.blank?) && self.official_link.present? && (doi_option_value_check? == true)
        self.file_availability = ['File not available']
          puts"LONDONN26"

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] } || get_work_filesets_visibility.blank?) && self.official_link.present? && (doi_option_value_check? == false)
          self.file_availability = ['File not available']
            puts"LONDONN27"

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] } || get_work_filesets_visibility.blank?) && !self.official_link.present? && (doi_option_value_check? == true)
        self.file_availability = ['File not available']
          puts"LONDONN28"

      elsif (get_work_filesets_visibility.any? {|status| status.in? ['authenticated', 'restricted'] } || get_work_filesets_visibility.blank?) && !self.official_link.present? && (doi_option_value_check? == false)
        self.file_availability = ['File not available']
          puts"LONDONN29"
      end
    end

    def doi_option_value_check?
      self.doi_options.in? ["Mint DOI:Registered", "Mint DOI:Findable"]
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
