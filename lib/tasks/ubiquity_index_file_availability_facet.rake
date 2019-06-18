#run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
# rake ubiquity_index_file_availability_facet:update['sandbox.repo-test.ubiquity.press']

namespace :ubiquity_index_file_availability_facet do
  desc "Run this task to popolate the file_availability field for existing works"

  task :update, [:name] => :environment do |task, tenant|

    #These are the names of the existing work type in UbiquityPress's Hyku
    model_class = [Collection, Article, Book, BookContribution, ConferenceItem, Dataset, Exhibition, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork]
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

end
