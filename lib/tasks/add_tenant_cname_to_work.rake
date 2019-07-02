#run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
#for example if the tenant cname is 'sandbox.repo-test.ubiquity.press' run as shown below
# rake add_tenant_cname_to_work:update['sandbox.repo-test.ubiquity.press']


namespace :add_tenant_cname_to_work do
  desc "Add tenant cname to works created before the feature to add tenant cname
       to work was implemented"

  task :update, [:name] => :environment do |task, tenant|
    #These are the names of the existing work type in UbiquityPress's Hyku
    model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork, Collection, FileSet]
    cname = tenant[:name]
    AccountElevator.switch!("#{cname}")

    model_class.each do |model|
      all_records = model.where(account_cname: nil)
      all_records.each do |model_instance|
        if model_instance.account_cname.blank?
          model_instance.update(account_cname: cname)
          sleep 2
        end
      end
    end

  end
end
