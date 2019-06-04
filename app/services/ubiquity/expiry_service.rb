module Ubiquity
  class  ExpiryService
    attr_accessor :embargo_works, :lease_works,
                :embargo_fileset, :lease_fileset,
                :model_class, :tenant_names

  #adds get_visibility_after_expiration and compare_visibility?
    include Ubiquity::ExpiryUtil

    #A typical embargo_works and lease_works hash when populated looks like:
        # [{id: [], work_class: '', expiry_type: '', tenant: ''}]
    # A populated lease_fileset and embargo_fileset looks like:
       # [{id: [], expiry_type: '', tenant: ''}]
    #expiry_type is either lease or embargo
    #model_class are the names of the existing work types in UbiquityPress's Hyku
    #
    def initialize
      @embargo_works = []
      @lease_works = []
      @embargo_fileset = []
      @lease_fileset = []
      @model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]
      @tenant_names = Account.where.not(data: {'is_parent': 'true'}).pluck(:cname)
      fetch_records
    end

    def fetch_records
      iterate_over_tenant_record
      self
    end

    def release_embargo!
      embargo_works.each do |hash|
        work_id = hash[:id]
        work_class = hash[:work_class].to_s
        type = hash[:expiry_type]
        tenant = hash[:tenant]
        UbiquityWorkExpiryJob.perform_later(work_id, work_class, type, tenant)
      end
      self
      rescue ActiveFedora::ObjectNotFoundError
        puts "error in release_embargo! in UbiquityExpiryService"

    end

    def release_lease!
      lease_works.each do |hash|
        work_id = hash[:id]
        work_class = hash[:work_class].to_s
        type = hash[:expiry_type]
        tenant = hash[:tenant]
        UbiquityWorkExpiryJob.perform_later(work_id, work_class, type, tenant)
      end
      self
    end

    def release_embargo_on_files!
      embargo_fileset.each do |hash|
        file_set_id = hash[:id]
        type = hash[:expiry_type]
        tenant = hash[:tenant]
        UbiquityFileExpiryJob.perform_later(file_set_id, type, tenant)
      end
      self
    end

    def release_lease_on_files!
      lease_fileset.each do |hash|
        file_set_id = hash[:id]
        type = hash[:expiry_type]
        tenant = hash[:tenant]
        UbiquityFileExpiryJob.perform_later(file_set_id, type, tenant)
      end
      self
    end

    private

    def iterate_over_tenant_record
      tenant_names.each do |tenant_name|
        fetch_embargo_records_for_single_tenant(tenant_name)
        fetch_lease_records_for_single_tenant(tenant_name)
      end
    end

    def fetch_embargo_records_for_single_tenant(tenant_name)
      AccountElevator.switch!("#{tenant_name}")
      model_class.each do |model|
        model.find_each do |model_instance|
          if ( (model_instance.embargo.present? && (not model_instance.under_embargo?) && model_instance.visibility != model_instance.visibility_after_embargo && model_instance.embargo_release_date.present? && model_instance.embargo_release_date.past?) ) # (model_instance.visibility_after_embargo != model_instance.visibility)&& (model_instance.visibility_after_embargo != model_instance.visibility)
            set_method_values(model_instance, model, tenant_name, 'embargo')
          elsif  model_instance.embargo.present? && (not model_instance.under_embargo?) && (not model_instance.embargo_release_date.present?) && (compare_visibility_after_expiration?(model_instance, 'embargo') )#needs_visibility_reset
            set_method_values(model_instance, model, tenant_name, 'embargo')
          end
          #on the assumption that files could be embargoed even if the work is not under embargo or have different expirartion date
          add_files_with_embargo(model_instance, tenant_name)
        end
      end
    end

    def fetch_lease_records_for_single_tenant(tenant_name)
      AccountElevator.switch!("#{tenant_name}")
      model_class.each do |model|
        model.find_each do |model_instance|
          if (( model_instance.lease.present? && (not model_instance.active_lease?) && model_instance.visibility != model_instance.visibility_after_lease && model_instance.lease_expiration_date.present? && model_instance.lease_expiration_date.past? ) )
            set_method_values(model_instance, model, tenant_name, 'lease')
          elsif  model_instance.lease.present? && (not model_instance.active_lease?) && (not model_instance.lease_expiration_date.present?) && compare_visibility_after_expiration?(model_instance, 'lease')#needs_visibility_reset
            set_method_values(model_instance, model, tenant_name, 'lease')
          end
          sleep 1
          #on the assumption that files could be lease even if the work is not under lease or have different expirartion date
          add_files_with_lease(model_instance, tenant_name)
        end
      end
    end

    def add_files_with_embargo(model_instance, tenant_name)
      set_values_fileset_arrays(model_instance, tenant_name, 'embargo')
    end

    def  add_files_with_lease(model_instance, tenant_name)
      set_values_fileset_arrays(model_instance, tenant_name, 'lease')
    end

    def lease_file_ids(file_set, type)
      if (file_set.present? && file_set.send(type).present? && file_set.visibility != file_set.send("visibility_after_#{type}") && file_set.lease_expiration_date.present? && file_set.lease_expiration_date.past?)
        file_set.id
      elsif file_set.lease.present? && (not file_set.active_lease?) && (not file_set.lease_expiration_date.present?) && compare_visibility_after_expiration?(file_set, 'lease')#needs_visibility_reset
        file_set.id
      end
    end

    def embargo_file_ids(file_set, type)
      if (file_set.present? && file_set.embargo.present? && file_set.visibility != file_set.visibility_after_embargo && file_set.embargo_release_date.present? && file_set.embargo_release_date.past?)
        file_set.id
      elsif  file_set.embargo.present? && (not file_set.under_embargo?) && (not file_set.embargo_release_date.present?) && compare_visibility_after_expiration?(file_set, 'embargo')#needs_visibility_reset
        file_set.id
      end
    end

    def build_hash
      {id: [], work_class: '', expiry_type: '', tenant: ''}
    end

    def populate_new_hash(id, model_klass, tenant_name, type)
      hash = build_hash
      #note id is an array
      hash[:id] |=  id
      hash[:expiry_type] = type
      hash[:work_class] = model_klass
      hash[:tenant] = tenant_name
      hash
    end

    def fetch_hash(method_name, hash_value, tenant_name)
      array_method = self.send(method_name.to_sym)
      array_method.find {|hash| (hash[:work_class] == hash_value && hash[:tenant] == tenant_name)} if array_method.first.class == Hash
    end

    def  set_method_values(model_instance, model, tenant_name, type)
      method_name = "#{type}_works"
      data = self.send(method_name)
      work_hash = fetch_hash(method_name, model.to_s, tenant_name) if method_name.present?
      if (not work_hash.present?)
        hash = populate_new_hash([model_instance.id], model.to_s, tenant_name, type)
        data = [data] if data.class == Hash
        data |= [hash]
        self.send("#{method_name}=", data) #if (hash[:tenant] == tenant_name)
      elsif (work_hash.present? && work_hash[:tenant] == tenant_name)
        work_hash[:id] |= [model_instance.id]
        data |= [work_hash]
        self.send("#{method_name}=", data)
      end
    end

    def set_values_fileset_arrays(model_instance, tenant_name, type)
      if model_instance.file_sets.present?
        hash_value = "#{model_instance.class}_fileset"
        method_name = "#{type}_fileset"
        work_hash = fetch_hash(method_name, hash_value, tenant_name) if method_name.present?
        #file_ids = model_instance.file_sets.map {|file_set| file_set.id if (file_set.present? && file_set.lease.present? && file_set.visibility != file_set.visibility_after_lease && file_set.lease_expiration_date.present? && file_set.lease_expiration_date.past?) }
        list_file_ids = file_ids(model_instance, type)
        file_id_array = list_file_ids.flatten.compact
        data = self.send(method_name)
      end
      if file_id_array.present? &&  (not work_hash.present?)
        hash = populate_new_hash(file_id_array, hash_value, tenant_name, type)
        #@lease_fileset |= [hash]
        data |= [hash]
        self.send("#{method_name}=", data) #if (hash[:tenant] == tenant_name)
      elsif file_id_array.present? && work_hash.present? && (work_hash[:tenant] == tenant_name)
        work_hash[:id] |= file_id_array
        #@lease_fileset |= [work_hash]
        data |= [work_hash]
        self.send("#{method_name}=", data)
      end
    end

    def file_ids(model_instance, type)
      model_instance.file_sets.map do |file_set|
        if type == "lease"
          lease_file_ids(file_set, type)
        elsif type == "embargo"
          embargo_file_ids(file_set, type)
        end
      end
    end

  end
end
