module Ubiquity
  module AllModelsVirtualFields
    extend ActiveSupport::Concern

    included do

      before_save :save_contributor
      before_save :save_creator
      before_save :save_funder
      before_save :save_alternate_identifier
      before_save :save_related_identifier
      before_save :save_date_published, :save_date_accepted, :save_date_submitted,
                  :save_event_date, :save_related_exhibition_date
      before_save :save_current_he_institution

      after_save :update_external_service_record, :create_work_service_if_embargo_or_lease

      #These are used in the forms to populate fields that will be stored in json fields
      #The json fields in this case are creator, contributor, alternate_identifier, related_identifier and current_he_institution
      attr_accessor :creator_group, :contributor_group, :funder_group, :alternate_identifier_group, :related_identifier_group,
                    :date_published_group, :date_accepted_group, :date_submitted_group,
                    :event_date_group, :related_exhibition_date_group, :current_he_institution_group
    end

    private

      def update_external_service_record
        exter = ExternalService.where(draft_doi: self.draft_doi).first
        if exter.try(:work_id).blank?
          begin
            exter && exter.update!(work_id: self.id)
          rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid => e
            puts'ExternalService record not saved in the model'
            AddWorkIdToExternalServiceJob.perform_later(self.id, self.draft_doi, self.account_cname)
          end
        end
      end

      def create_work_service_if_embargo_or_lease
        if under_embargo? || active_lease?
          create_work_expiry_service
        end
      end

    #
    # We are addressing 2 use case for each json field
    # 1. When saving a new record
    #    a. loop through the array and reject empty or nil values from the hash.
    #    b. Using the data from 1a above, run an additionally t detect if the hash keys are meant for default values only.
    #    c. If step 1b returns true, then we just clear the array by settin the json field to an empty arry
    #
    # 2 when updating a record that has a mix, that is some hash need to be kept while removing those hash with only default values
    #    a. Same as step 1a and 1b Above
    #    b. Using the array of hash from the above step remove hash that contains only default keys and values.
    #    c. Save the the array of hashes from step 2b
    #
    def save_creator
      self.creator_group ||= JSON.parse(self.creator.first) if self.creator.present?
      #remove Hash with empty values and nil
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.creator_group)
      #Check if the hash keys are only those used for default values like position
      data = compare_hash_keys?(clean_submitted_data)

      if (self.creator_group.present? && clean_submitted_data.present? && data == false)
        creator_json = clean_submitted_data.to_json
        populate_creator_search_field(creator_json)
        self.creator = [creator_json]
      elsif data == true || data == nil
        self.creator_search = []
        #save an empty array since the submitted data contains only default keys & values
        self.creator = []
      end
    end

    def save_funder
      self.funder_group ||= Ubiquity::JsonValidator.valid_json?( self.funder.try(:first) ) ? JSON.parse(self.funder.first) : nil if self.funder.present?
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.funder_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.funder_group.present? && clean_submitted_data.present? && data == false )
        funder_json = clean_submitted_data.to_json
        self.funder = [funder_json]
      elsif data == true || data == nil
       self.funder = []
      end
    end

    def save_contributor
      self.contributor_group ||= JSON.parse(self.contributor.first) if self.contributor.present?
      clean_contributor_data(self.contributor_group)
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.contributor_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.contributor_group.present? && clean_submitted_data.present? && data == false )
        contributor_json = clean_submitted_data.to_json
        self.contributor = [contributor_json]
      elsif data == true || data == nil
       self.contributor = []
      end
    end

    def save_related_identifier
      self.related_identifier_group ||= JSON.parse(self.related_identifier.first) if self.related_identifier.present?
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.related_identifier_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.related_identifier_group.present?  && clean_submitted_data.present? && data == false)
        related_identifier_json = clean_submitted_data.to_json
        self.related_identifier = [related_identifier_json]
      elsif data == true || data == nil
       self.related_identifier = []
      end
    end

    def save_alternate_identifier
      self.alternate_identifier_group ||= JSON.parse(self.alternate_identifier.first) if self.alternate_identifier.present?
      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.alternate_identifier_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.alternate_identifier_group.present? && clean_submitted_data.present? && data == false)
       #remove any empty hash in the array
        clean_submitted_data = clean_submitted_data - [{}]
        alternate_identifier_json = clean_submitted_data.to_json
        self.alternate_identifier = [alternate_identifier_json]
      elsif data == true || data == nil
        self.alternate_identifier = []
      end
    end

    def save_date_published
      date ||= self.date_published if (self.date_published.present? && self.date_published.class == String)
      new_value = populate_date_field(date, date_published)
      self.date_published_group ||= new_value  if (new_value.present? && (not self.date_published_group.present?) )
      self.date_published = transform_date_group(date_published_group.first) if date_published_group
    end

    def save_date_accepted
      date ||= self.date_accepted if (self.date_accepted.present? && self.date_accepted.class == String)
      new_value = populate_date_field(date, date_accepted)
      self.date_accepted_group ||= new_value  if (new_value.present? && (not self.date_accepted_group.present?) )
      self.date_accepted = transform_date_group(date_accepted_group.first) if date_accepted_group
    end

    def save_date_submitted
      date ||= self.date_submitted if (self.date_submitted.present? && self.date_submitted.class == String)
      new_value = populate_date_field(date, date_accepted)
      self.date_submitted_group ||= new_value  if (new_value.present? && (not self.date_submitted_group.present?) )
      self.date_submitted = transform_date_group(date_submitted_group.first) if date_submitted_group
    end

    def save_event_date
      date ||= self.event_date if (self.event_date.present? && self.event_date.class == String)
      new_value = populate_date_field(date, event_date)
      self.event_date_group ||= new_value if (new_value.present? && (self.event_date_group.blank?) )
      dates = []
      if event_date_group
        event_date_group.each do |e|
          dates << transform_date_group(e).to_s
        end
      end
      self.event_date = dates.reject(&:blank?)
    end

    def save_related_exhibition_date
      date ||= self.related_exhibition_date if (self.related_exhibition_date.present? && self.related_exhibition_date.class == String)
      new_value = populate_date_field(date, related_exhibition_date)
      self.related_exhibition_date_group ||= new_value if (new_value.present? && (self.related_exhibition_date_group.blank?) )
      dates = []
      if related_exhibition_date_group
        related_exhibition_date_group.each do |e|
          dates << transform_date_group(e).to_s
        end
      end
      self.related_exhibition_date = dates.reject(&:blank?)
    end

    def save_current_he_institution
      self.current_he_institution_group ||=  Ubiquity::JsonValidator.valid_json?(self.current_he_institution.first) ?
                                  JSON.parse(self.current_he_institution.first) : nil if self.current_he_institution.present?

      clean_submitted_data ||= remove_hash_keys_with_empty_and_nil_values(self.current_he_institution_group)
      data = compare_hash_keys?(clean_submitted_data)
      if (self.current_he_institution_group.present? && clean_submitted_data.present? && data == false )
        current_he_institution_json = clean_submitted_data.to_json
        self.current_he_institution = [current_he_institution_json]
      elsif data == true || data == nil
        self.current_he_institution = []
     end
    end

    private

    def create_work_expiry_service
      work_service = WorkExpiryService.find_or_create_by(work_id: id)
      release_date = under_embargo? ? embargo.embargo_release_date : lease.lease_expiration_date
      work_service.update(work_type: 'work', tenant_name: account_cname, expiry_time: release_date)
    end

    #We parse the json in the an array before saving the value in creator_search
    def populate_creator_search_field(json_record)
      values = Ubiquity::ParseJson.new(json_record).data
      self.creator_search = values
    end

    #Check if the hash keys are only those used for default values like position
    def compare_hash_keys?(record)
      if record.present? && record.first.present?
        my_default_keys = get_default_hash_keys(record)
        keys_in_hash = record.map {|hash| hash.keys}.flatten.uniq
        (keys_in_hash == my_default_keys)
      else
        nil
      end
    end

    #remove hash keys with value of nil, "", and "NaN"
    def remove_hash_keys_with_empty_and_nil_values(data)
      if (data.present? && data.class == Array)
        new_data = data.map do |hash|
          ['contributor_orcid', 'contributor_isni', 'creator_orcid', 'creator_isni', 'editor_isni', 'editor_orcid'].each do|ele|
            hash[ele] = hash[ele].strip.chomp('/').split('/').last.gsub(/[^a-z0-9X-]/, '') if hash[ele].present?
          end
          hash.reject { |_k, v| v.nil? || v.to_s.empty? || v == "NaN" }
        end
        # remove hash that contains only default keys and values.
        remove_hash_with_default_keys(new_data)
      end
    end

    # remove any hash that contains only default keys and values.
    def remove_hash_with_default_keys(data)
      my_default_keys = get_default_hash_keys(data)
      new_data = data.reject do |hash|
        hash.keys.uniq == my_default_keys
      end
    end

    #data is an array of hash eg [{"contributor_organization_name"=>""}},{"contributor_name_type"=>"Personal"}]
    def get_default_hash_keys(data)
      if data.present? && data.first.present?
        #we get the first hash in the array and then get the first hash key
        record = data.first.keys.first || data

        splitted_record = record.split('_')

        #the value of record will be "contributor_organization_name" when using array of hash from the above comments
        #This means field name after the record.split will be 'contributor' and will change depending on the hash keys
        get_field_name ||= splitted_record.first
        return   ["#{get_field_name}_position"] if (data.length == 1 && splitted_record.last == "position")
        ["#{get_field_name}_name_type", "#{get_field_name}_position"]
      end
    end

    def transform_date_group(hash)
      # check the year field: `hash.first` returns the year key, for example: ["date_published_year", "2002"]
      if hash.first[1].present?
        date = ""
        # iterate over year, month, day to obtain a String in format: 'YYYY-MM-DD'
        # see 'all_forms_shared_behaviour'
        hash.each do |key, value|
          if value.present?
            date << '-' if key.exclude?('year') # add a `-` before month or day
            date << value
          else
            return date
          end
        end
        date
      end
    end

    def populate_date_field(date, name)
      if date.present? && name.present?
        Ubiquity::ParseDate.new(date, name).process_dates
      end
    end

    def clean_contributor_data(contributor_hash)
      contributor_hash.each do |hash|
        if (hash['contributor_family_name'].blank? && hash['contributor_organization_name'].blank?)
          hash.transform_values! { |v| nil }
        end
      end
    end
    
  end
end
