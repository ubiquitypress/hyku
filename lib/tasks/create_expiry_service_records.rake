namespace :create_expiry_service_records do
  desc "Rake task to populate the Embargo or Lease works to WrokExpiryService model"
  task :populate_data, [:name] => :environment do |task, tenant|
    model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, ThesisOrDissertation, TimeBasedMedia, Image, Report, GenericWork]
    AccountElevator.switch!(tenant[:name].to_s)
    model_class.each do |model_instance|
      model_instance.all.each do |work|
        embargo_or_lease_exist = work.embargo.present? || work.lease.present?
        next unless embargo_or_lease_exist
        embargo_lease_condition = work.embargo.try(:embargo_release_date).present? || work.lease.try(:lease_expiration_date).present?
        next unless embargo_lease_condition
        work_service = WorkExpiryService.find_or_create_by(work_id: work.id)
        release_date = work.embargo.try(:embargo_release_date).presence || work.lease.try(:lease_expiration_date)
        work_service.update(work_type: 'work', tenant_name: tenant[:name].to_s, expiry_time: release_date)
      end
    end
    puts "#{WorkExpiryService.count} records have been saved successfully"
  end
end
