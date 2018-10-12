#run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
# rake json_array:update['sandbox.repo-test.ubiquity.press']

namespace :json_array do
  desc "Remove from already saved json fields values such as  ['[{}]'] "
  #task update: :environment do
  #Note the variable task is the the task object and tenant represents the argument passed to the rake task
  task :update, [:name] => :environment do |task, tenant|

    #These are the names of the existing work type in UbiquityPress's Hyku
    model_class = [Collection, Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]

    AccountElevator.switch!("#{tenant[:name]}")
    model_class.each do |model|
      #We fetching an instance of the models and then getting the value in the creator field
      model.find_each do |model_instance|

        if model_instance.creator.first.present?
          creator =  JSON.parse(model_instance.creator.first)
          model_instance.creator_group =  creator
        end

        if model_instance.contributor.first.present?
          contributor =  JSON.parse(model_instance.contributor.first)
          model_instance.contributor_group = contributor
        end

        if model_instance.alternate_identifier.first.present?
          alternate_identifier =  JSON.parse(model_instance.alternate_identifier.first)
          model_instance.alternate_identifier_group = alternate_identifier
        end

        if model_instance.related_identifier.first.present?
          related_identifier =  JSON.parse(model_instance.related_identifier.first)
          model_instance.related_identifier_group = related_identifier
        end

        if model_instance.editor.first.present?
          editor =  JSON.parse(model_instance.editor.first)
          model_instance.editor_group = editor
        end

        model_instance.save
        sleep 2

      end
    end

  end
end
