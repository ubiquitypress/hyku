#run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
#for example if the tenant cname is 'sandbox.repo-test.ubiquity.press' run as shown below
# rake ubiquity_work_reindex:update['sandbox.repo-test.ubiquity.press']


namespace :ubiquity_work_reindex do
  desc "Reindex all works when necessary"

  task :update, [:name] => :environment do |task, tenant|
    cname = tenant[:name]
    AccountElevator.switch!("#{cname}")
    ActiveFedora::Base.reindex_everything
  end
end
