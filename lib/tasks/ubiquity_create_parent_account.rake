## rake ubiquity_create_parent_account:update['sandbox.repo-test.ubiquity.press']

namespace :ubiquity_create_parent_account do
  desc "create the root account or parent or main tenant that can have other tenants. "

  task :update, [:name] => :environment do |task, tenant|
    cname = tenant[:name]
    account = Account.find_or_initialize_by(cname: cname)
    account.data['is_parent'] =  'true'
    if account.new_record?
      puts "creating new parent tenant or account #{account.inspect}"
       CreateAccount.new(account).save
    else
      "puts updating existing parent tenant or account #{account.inspect}"
      account.save
    end
  end
end
