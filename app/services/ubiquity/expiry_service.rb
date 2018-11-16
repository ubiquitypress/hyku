module Ubiquity
  class  ExpiryService
    attr_reader :embargo_works, :leased_works,
                :embargo_fileset, :leased_fileset,
                :model_class, :tenant_names

    #A typical embargo_works and leased_works hash when populated looks like:
        # {id: [], work_class: '', expiry_type: '', tenant: ''}
    # A populated leased_fileset and embargo_fileset looks like:
       # {id: [], expiry_type: '', tenant: ''}
    #expiry_type is either lease or embargo
    #model_class are the names of the existing work types in UbiquityPress's Hyku
    #
    def initialize
      @embargo_works = {id: []}
      @leased_works = {id: []}
      @embargo_fileset = {id: []}
      @leased_fileset = {id: []}
      @model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]
      @tenant_names = Account.pluck(:cname)
      fetch_records
    end

    def fetch_records
      iterate_over_tenant_record
      self
    end

    def release_embargo!
      embargo_works[:id].each do |index|
        work_id = embargo_works[:id][index]
        work_class = embargo_works[:work_class]
        type = embargo_works[:expiry_type]
        tenant = embargo_works[:tenant]
        UbiquityWorkExpiryJob(work_id, work_class, type, tenant)
      end
      self
      rescue ActiveFedora::ObjectNotFoundError
        puts "new-brexit dont-embargo-me"

    end

    def release_lease!
      @leased_works[:id].each do |index|
        work_id = leased_works[:id][index]
        work_class = leased_works[:work_class]
        type = leased_works[:expiry_type]
        tenant = leased_works[:tenant]
        UbiquityWorkExpiryJob(work_id, work_class, type, tenant)
      end
      self
    end

    def release_embargo_on_files!
      embargo_fileset[:id].each do |index|
        file_set_id = embargo_fileset[:id][index]
        type = embargo_fileset[:expiry_type]
        tenant = embargo_fileset[:tenant]
        UbiquityFileExpiryJob.perform_now(file_set_id, type, tenant)
      end
      self
    end

    def release_lease_on_files!
      leased_fileset[:id].each do |index|
        file_set_id = leased_fileset[:id][index]
        type = leased_fileset[:expiry_type]
        tenant = leased_fileset[:tenant]
        UbiquityFileExpiryJob.perform_now(file_set_id, type, tenant)
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
         if model_instance.embargo.present? && model_instance.visibility != model_instance.visibility_after_embargo && model_instance.embargo_release_date.present? && model_instance.embargo_release_date.past? && (model_instance.visibility_after_embargo != model_instance.visibility)
            @embargo_works[:id] << model_instance.id
            @embargo_works[:expiry_type] = 'embargo'
            @emabrgo_works[:work_class] = model
            @embargo_works[:tenant] = tenant_name
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
        #We fetching an instance of the models and then getting the value in the creator field
        model.find_each do |model_instance|
         if model_instance.lease.present? && model_instance.visibility != model_instance.visibility_after_lease && model_instance.lease_expiration_date.present? && model_instance.lease_expiration_date.past? && (model_instance.visibility_after_lease != model_instance.visibility)
            @leased_works[:id] << model_instance.id
            @leased_works[:expiry_type] = 'lease'
            @leased_works[:work_class] = model
            @leased_works[:tenant] = tenant_name
            sleep 1
          end
          #on the assumption that files could be leased even if the work is not under lease or have different expirartion date
          add_files_with_lease(model_instance, tenant_name)
        end
      end
    end

    def add_files_with_embargo(model_instance, tenant_name)
      if model_instance.file_sets.present?
        @embargo_fileset[:tenant] = tenant_name
        @embargo_fileset[:expiry_type] = 'embargo'
        @embargo_fileset[:id] << model_instance.file_sets.map {|file_set| file_set.id if (file_set.present? && file_set.embargo.present? && file_set.visibility != file_set.visibility_after_embargo && file_set.embargo_release_date.present? && file_set.embargo_release_date.past?) }
        @embargo_fileset[:id]  =  @embargo_fileset[:id].flatten.compact
      end
    end

    def  add_files_with_lease(model_instance, tenant_name)
      if model_instance.file_sets.present?
         @leased_fileset[:tenant] = tenant_name
         @leased_fileset[:expiry_type] = 'lease'
         @leased_fileset[:id] << model_instance.file_sets.map {|file_set| file_set.id if (file_set.present? && file_set.lease.present? && file_set.visibility != file_set.visibility_after_lease && file_set.lease_expiration_date.present? && file_set.lease_expiration_date.past?) }
         @leased_fileset[:id] = @leased_fileset[:id].flatten.compact
      end
    end

  end
end
