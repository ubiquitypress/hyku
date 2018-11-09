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
    model_class = [Collection, Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]
    AccountElevator.switch!("#{tenant[:name]}")
    model_class.each do |model|
      #We fetching an instance of the models and then getting the value in the creator field
      model.find_each do |model_instance|
        if model_instance.model_name != "Collection"
          json_creator_record = model_instance.creator.first
          contributor_record = Ubiquity::ParseJson.new(model_instance.contributor.first).parsed_json
          alt_id_record = Ubiquity::ParseJson.new(model_instance.alternate_identifier.first).parsed_json
          related_id_record = Ubiquity::ParseJson.new(model_instance.related_identifier.first).parsed_json
          if json_creator_record.present?
            #We parse the json in the an array before saving the value in creator_search
            values = Ubiquity::ParseJson.new(json_creator_record).data
            if model_instance.respond_to?(:editor)
              editor_record = Ubiquity::ParseJson.new(model_instance.editor.first).parsed_json
              model_instance.update(creator_search: values,
                                    creator_group:  Ubiquity::ParseJson.new(json_creator_record).parsed_json,
                                    contributor_group: contributor_record,
                                    alternate_identifier_group: alt_id_record,
                                    related_identifier_group: related_id_record,
                                    editor_group: editor_record)
            else
              model_instance.update(creator_search: values,
                                    creator_group: Ubiquity::ParseJson.new(json_creator_record).parsed_json,
                                    contributor_group: contributor_record,
                                    alternate_identifier_group: alt_id_record,
                                    related_identifier_group: related_id_record)
            end
            sleep 2
          else
            if model_instance.respond_to?(:editor)
              model_instance.update(creator_search: [],
                                    contributor_group: contributor_record,
                                    alternate_identifier_group: alt_id_record,
                                    related_identifier_group: related_id_record,
                                    editor_group: editor_record)
            else
              model_instance.update(creator_search: [],
                                    contributor_group: contributor_record,
                                    alternate_identifier_group: alt_id_record,
                                    related_identifier_group: related_id_record)
            end
            sleep 2
          end
        end
      end
    end

  end
end
