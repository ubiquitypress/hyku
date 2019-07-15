#run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
# rake ubiquity_resave_records:all['sandbox.repo-test.ubiquity.press']
#for updatinga specific model note the surrounding string after the rake command
# rake "ubiquity_resave_records:update_specific_model[sandbox.repo-test.ubiquity.press,  generic_work]"
#
# rake ubiquity_resave_records:all_exempt_collections['sandbox.repo-test.ubiquity.press']


namespace :ubiquity_resave_records do
  desc "Update data by resaving records for existing works"

  task :all, [:name] => :environment do |task, tenant|

    #These are the names of the existing work type in UbiquityPress's Hyku
    model_class = [Collection, Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork]
    AccountElevator.switch!("#{tenant[:name]}")
    model_class.each do |model|
      #We fetching an instance of the models and then getting the value in the creator field
      model.find_each do |model_instance|
         #by calling save we trigger the before_save callback in app/models/ubiquity/concerns/multiple_modules.rb
          model_instance.save
          sleep 2
      end
    end
  end

  task :all_exempt_collections, [:name] => :environment do |task, tenant|

    #These are the names of the existing work type in UbiquityPress's Hyku
    model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork]
    AccountElevator.switch!("#{tenant[:name]}")
    model_class.each do |model|
      #We fetching an instance of the models and then getting the value in the creator field
      model.find_each do |model_instance|
         #by calling save we trigger the before_save callback in app/models/ubiquity/concerns/multiple_modules.rb
          model_instance.save
          sleep 2
      end
    end
  end

  task :update_specific_model, [:tenant_name, :model_name] => :environment do |task, args|
    tenant_name = args[:tenant_name]
    puts "tenant_cname in file_availability rake task: #{tenant_name}"
    AccountElevator.switch!(tenant_name)
    model = args[:model_name]
    model_class = model.to_s.classify.constantize
    puts "model_name  in file_availability rake task: #{model_class}"

    model_class.find_each do |model_instance|
      puts "model_id in in file_availability rake task:   #{model_instance.id}"
       #by calling save we trigger the before_save callback in app/models/ubiquity/concerns/multiple_modules.rb
      model_instance.save
      sleep 2
    end
  end

end
