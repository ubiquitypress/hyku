module Ubiquity
  class  ExpiryService
    attr_reader :embargo_records_for_update, :leased_records_for_update,
                :embargo_fileset, :leased_fileset

    def initialize
      @embargo_records_for_update = []
      @leased_records_for_update = []
      @embargo_fileset = {id: []}
      @leased_fileset = {id: []}
      fetch_records
    end

    def fetch_records
      #These are the names of the existing work type in UbiquityPress's Hyku
      model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]
      # Dynamically get tenant names
      get_tenant_names = Account.pluck(:cname)
      if get_tenant_names.length == 1
        tenant_name = get_tenant_names.first
        fetch_embargo_records_for_single_tenant(tenant_name, model_class)
        fetch_lease_records_for_single_tenant(tenant_name, model_class)
      elsif get_tenant_names.length > 1
        iterate_over_tenant_record(get_tenant_names)
      end
      self
    end

    def release_embargo!
      @embargo_records_for_update.each do |work|
        Hyrax::Actors::EmbargoActor.new(work).destroy
        sleep 1
      end
      self
    end

    def release_lease!
      @leased_records_for_update.each do |work|
        Hyrax::Actors::LeaseActor.new(work).destroy
        sleep 1
      end
      self
    end

    def release_embargo_on_files!
      records = fetch_embargo_file_set
      tenant = embargo_fileset[:tenant]
      if records.present?
        records.each do |file_set|
          UbiquityFileExpiryJob.perform_now(file_set, 'embargo', tenant)
        end
      end
      self
    end

    def release_lease_on_files!
      records = fetch_lease_file_set
      tenant = leased_fileset[:tenant]
      if records.present?
        records.each do |file_set|
          UbiquityFileExpiryJob.perform_now(file_set, 'lease', tenant)
        end
      end
      self
    end

    private
    def iterate_over_tenant_record(tenant_names)
      tenant_names.each do |name|
        fetch_embargo_records_for_single_tenant(tenant_name, model_class)
        fetch_lease_records_for_single_tenant(tenant_name, model_class)
      end
    end

    def fetch_embargo_records_for_single_tenant(tenant_name, model_class)
      AccountElevator.switch!("#{tenant_name}")
      model_class.each do |model|
        model.find_each do |model_instance|
         if model_instance.embargo.present? && model_instance.embargo_release_date.present? && model_instance.embargo_release_date.past? && (model_instance.visibility_after_embargo != model_instance.visibility)
            @embargo_records_for_update << model_instance
            sleep 1
          end
          add_files_with_embargo(model_instance, tenant_name)
        end
      end
      self
    end

    def fetch_lease_records_for_single_tenant(tenant_name, model_class)
      AccountElevator.switch!("#{tenant_name}")
      model_class.each do |model|
        #We fetching an instance of the models and then getting the value in the creator field
        model.find_each do |model_instance|
         if model_instance.lease.present? && model_instance.lease_expiration_date.present? && model_instance.lease_expiration_date.past? && (model_instance.visibility_after_lease != model_instance.visibility)
            @leased_records_for_update << model_instance
            sleep 1
          end
          #on the assumption that files have a different expirartion date
          add_files_with_lease(model_instance, tenant_name)
        end
      end
      self
    end

    def add_files_with_embargo(model_instance, tenant_name)
      if model_instance.file_sets.present?
        @embargo_fileset[:tenant] = tenant_name
        @embargo_fileset[:id] << model_instance.file_sets.map {|file_set| file_set.id if (file_set.embargo_release_date.present? && file_set.embargo_release_date.past?) }
        @embargo_fileset[:id]  =  @embargo_fileset[:id].flatten.compact
      end
    end

    def  add_files_with_lease(model_instance, tenant_name)
      if model_instance.file_sets.present?
         @leased_fileset[:tenant] = tenant_name
         @leased_fileset[:id] << model_instance.file_sets.map {|file_set| file_set.id if (file_set.lease_expiration_date.present? && file_set.lease_expiration_date.past?) }
         @leased_fileset[:id] = @leased_fileset[:id].flatten.compact
      end
    end

    def fetch_lease_file_set
      FileSet.where(id: leased_fileset[:id])
    end

    def fetch_embargo_file_set
      FileSet.where(id: embargo_fileset[:id])
    end

  end
end
