# rake ubiquity_populate_account_parent_id:update['localhost']

namespace :ubiquity_populate_account_parent_id do
  desc "create the root account or parent or main tenant that can have other tenants. "

  task :update, [:name] => :environment do |task, tenant|
    cname = tenant[:name]
    parent = Account.where("cname ILIKE ?", "%#{cname}%").where(data: {is_parent: 'true'}).first
    accounts = Account.where("cname ILIKE ?", "%#{cname}%").where.not(data: {is_parent: 'true'})
    demo_records = accounts.map {|acct| j if acct.cname.include? 'demo'}.compact
    live_records = accounts - demo_records

    if parent.present?
      live_records.each do |record|
        puts "updating record with cname of #{record.cname} and id #{record.id} to belong to parent with cname of #{parent.cname} with parent id #{parent.id}"
        #AccountElevator.switch!(record)
        record.data['is_parent'] =  'false'  if record.data['is_parent'].blank?
        record.parent_id = parent.id         if record.parent_id.blank?
        record.settings['include_in_shared_search'] = 'true'  if record.settings['include_in_shared_search'].blank?
        record.save
     end
    end

    if parent.present?
      demo_records.each do |record|
        puts "updating record with cname of #{record.cname} and id #{record.id} to belong to parent with cname of #{parent.cname} with parent id #{parent.id}"
        #AccountElevator.switch!(record)
        record.data['is_parent'] =  'false'  if record.data['is_parent'].blank?
        record.parent_id = parent.id   if record.parent_id.blank?
        record.settings['include_in_shared_search'] = 'false'  if record.settings['include_in_shared_search'].blank?

        record.save
     end
    end

  end
end
