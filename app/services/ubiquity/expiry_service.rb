module Ubiquity
  class  ExpiryService
    attr_accessor :embargo_works, :lease_works,
                :embargo_fileset, :lease_fileset,
                :model_class, :tenant_names

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
      @tenant_names = Account.pluck(:cname)
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
          if model_instance.embargo.present? && model_instance.visibility != model_instance.visibility_after_embargo && model_instance.embargo_release_date.present? && model_instance.embargo_release_date.past? # (model_instance.visibility_after_embargo != model_instance.visibility)&& (model_instance.visibility_after_embargo != model_instance.visibility)
            work_hash = fetch_hash('embargo_works', model.to_s) if embargo_works.present?
            if (not work_hash.present?)
              hash = populate_new_hash(model_instance.id, model.to_s, tenant_name, 'embargo')
              @embargo_works |= [hash]
            elsif (work_hash.present? && work_hash[:tenant] == tenant_name)
              work_hash[:id] |= [model_instance.id]
              @embargo_works |= [work_hash]
            end
            sleep 1
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
          if model_instance.lease.present? && model_instance.visibility != model_instance.visibility_after_lease && model_instance.lease_expiration_date.present? && model_instance.lease_expiration_date.past? && (model_instance.visibility_after_lease != model_instance.visibility)
            work_hash = fetch_hash('lease_works', model.to_s) if lease_works.present?
            #If no hash with this work type is in the array, push a new hash
            if (not work_hash.present?)
              hash = populate_new_hash(model_instance.id, model.to_s, tenant_name, 'lease')
              @lease_works |= [hash]
          elsif (work_hash.present? && (work_hash[:tenant] == tenant_name))
              #update just the id of the hash in the array
              work_hash[:id] |= [model_instance.id]
              @lease_works |= [work_hash]
            end
            sleep 1
          end
          #on the assumption that files could be lease even if the work is not under lease or have different expirartion date
          add_files_with_lease(model_instance, tenant_name)
        end
      end
    end

    def add_files_with_embargo(model_instance, tenant_name)
      if model_instance.file_sets.present?
        hash_value = "#{model_instance.class}_fileset"
        work_hash = fetch_hash('embargo_fileset', hash_value) if embargo_fileset.present?
        file_ids = model_instance.file_sets.map {|file_set| file_set.id if (file_set.present? && file_set.embargo.present? && file_set.visibility != file_set.visibility_after_embargo && file_set.embargo_release_date.present? && file_set.embargo_release_date.past?) }
        file_id_array = file_ids.flatten.compact
      end

      if file_id_array.present? && (not work_hash.present?)
        hash = populate_new_hash(file_id_array, hash_value, tenant_name, 'embargo')
        @embargo_fileset |= [hash]
      elsif file_id_array.present? && work_hash.present? && (work_hash[:tenant] == tenant_name)
        work_hash[:id] |= file_id_array
        @embargo_fileset |= [work_hash]
      end
    end

    def  add_files_with_lease(model_instance, tenant_name)
      if model_instance.file_sets.present?
        hash_value = "#{model_instance.class}_fileset"
        work_hash = fetch_hash('lease_fileset', hash_value) if lease_fileset.present?
        file_ids = model_instance.file_sets.map {|file_set| file_set.id if (file_set.present? && file_set.lease.present? && file_set.visibility != file_set.visibility_after_lease && file_set.lease_expiration_date.present? && file_set.lease_expiration_date.past?) }
        file_id_array =file_ids.flatten.compact
      end
      if file_id_array.present? &&  (not work_hash.present?)
        hash = populate_new_hash(file_id_array, hash_value, tenant_name, 'lease')
        @lease_fileset |= [hash]
      elsif file_id_array.present? && work_hash.present? && (work_hash[:tenant] == tenant_name)
        work_hash[:id] |= file_id_array
        @lease_fileset |= [work_hash]
      end
    end

    def build_hash
      {id: [], work_class: '', expiry_type: '', tenant: ''}
    end

    def populate_new_hash(ids, model_klass, tenant_name, type)
      hash = build_hash
      hash[:id] |=  ["#{ids}"]
      hash[:expiry_type] = "#{type}"
      hash[:work_class] = "#{model_klass}"
      hash[:tenant] = "#{tenant_name}"
      hash
    end

    def fetch_hash(method_name, hash_value)
      array_method = self.send(method_name.to_sym)
      array_method.find {|hash| hash[:work_class] == hash_value} if array_method.first.class == Hash
    end

  end
end
