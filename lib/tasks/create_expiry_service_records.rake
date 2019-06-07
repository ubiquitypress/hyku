namespace :create_expiry_service_records do
  desc "Rake task to populate the Embargo or Lease works to WrokExpiryService model"
  task :populate_data, [:name] => :environment do |task, tenant|
    model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]
    AccountElevator.switch!(tenant[:name].to_s)
    model_class.each do |model_instance|
      model_instance.all.each do |work|
        embargo_lease_condition = work.under_embargo? || work.active_lease?
        next unless embargo_lease_condition
        work_service = WorkExpiryService.find_or_create_by(work_id: work.id)
        release_date = work.under_embargo? ? work.embargo.embargo_release_date : work.lease.lease_expiration_date
        work_service.update(work_type: 'work', tenant_name: tenant[:name].to_s, status: 'pending', expiry_time: release_date)
      end
    end
    puts "#{WorkExpiryService.count} records have been saved successfully"
  end
end
