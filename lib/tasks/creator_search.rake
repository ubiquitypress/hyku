#run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
# rake creator_search:update['sandbox.repo-test.ubiquity.press']

namespace :creator_search do
  desc "Populate creator_search fields using existing json values from creator metadata field for all work types"
  #task update: :environment do
  #Note the variable task is the the task object and tenant represents the argument passed to the rake task
  task :update, [:name] => :environment do |task, tenant|

    #These are the names of the existing work type in UbiquityPress's Hyku
    model_class = [Collection, Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork]
    AccountElevator.switch!("#{tenant[:name]}")
    model_class.each do |model|
      #We fetching an instance of the models and then getting the value in the creator field
      model.find_each do |model_instance|
        json_record = model_instance.creator.first
        if json_record.present?
          #We parse the json in the an array before saving the value in creator_search
          values = Ubiquity::ParseJson.new(json_record).data
          model_instance.update(creator_search: values)
          sleep 2
        end
      end
    end

  end
end
