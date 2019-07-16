## rake update_kew_institution:update['sandbox.repo-test.ubiquity.press']
#  rake update_kew_institution:update["ashik.localhost"]

namespace :update_kew_institution do
  desc "Task to update the Kew institution to `Royal Botanic Gardens, Kew`"
  task :update, [:name] => :environment do |_task, tenant|
    AccountElevator.switch!(tenant[:name].to_s)
    model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork]
    model_class.each do |model|
      puts "Updating the model *****#{model}*****"
      model.where(institution: 'Kew').each do |record|
        record.institution = ['Royal Botanic Gardens, Kew']
        if record.save
          puts 'Updated Successfully'
        else
          puts 'An error has been occured for the record' + record.id
        end
      end
    end
  end
end
