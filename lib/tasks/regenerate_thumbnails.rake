#run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
#for example if the tenant cname is 'sandbox.repo-test.ubiquity.press' run as shown below
#rake "regenerate_thumbnails:specific_model[sandbox.repo-test.ubiquity.press,  article]"
#rake "regenerate_thumbnails:specific_model[sandbox.repo-test.ubiquity.press,  generic_work]"
#rake "regenerate_thumbnails:specific_work[sandbox.repo-test.ubiquity.press,  f42646da-ac75-419c-b780-98129a7a739d]"

namespace :regenerate_thumbnails do
  desc "Regenerate thumbnail for works"

  task :all_work, [:tenant_name] => :environment do |task, args|
    regenerator = Ubiquity::RegenerateThumbnail.new(tenant: args[:tenant_name])
    regenerator.run
  end

  task :specific_model, [:tenant_name, :model_name] => :environment do |task, args|
    regenerator = Ubiquity::RegenerateThumbnail.new(tenant: args[:tenant_name], model_name: args[:model_name])
    regenerator.run
  end


  task :specific_work, [:tenant_name, :work_id] => :environment do |task, args|
    regenerator = Ubiquity::RegenerateThumbnail.new(tenant: args[:tenant_name], work_id: args[:work_id])
    regenerator.run
  end

end
