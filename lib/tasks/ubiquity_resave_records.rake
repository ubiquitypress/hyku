#run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
# rake ubiquity_resave_records:all['sandbox.repo-test.ubiquity.press']
#for updatinga specific model note the surrounding string after the rake command
# rake "ubiquity_resave_records:update_specific_model[sandbox.repo-test.ubiquity.press,  generic_work]"
#
# rake ubiquity_resave_records:all_exempt_collections['sandbox.repo-test.ubiquity.press']
# rake 'ubiquity_resave_records:where_metatdata_field_not_empty[library.localhost, editor_tesim]'
#
#rake ubiquity_resave_records:reassign_work_out_of_fedora_collection_assoc['sandbox.repo-test.ubiquity.press']
#run with
# rake ubiquity_resave_records:all['sandbox.repo-test.ubiquity.press']
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

  ##rake ubiquity_resave_records:reassign_work_out_of_fedora_collection_assoc['sandbox.repo-test.ubiquity.press']
  desc "Update data by resaving records for existing works"
  task :reassign_work_out_of_fedora_collection_assoc, [:name] => :environment do |task, tenant|

    #These are the names of the existing work type in UbiquityPress's Hyku
    AccountElevator.switch!("#{tenant[:name]}")
    work_list =  '(has_model_ssim:Article OR has_model_ssim:Book OR has_model_ssim:BookContribution OR has_model_ssim:ConferenceItem OR has_model_ssim:Dataset OR has_model_ssim:ExhibitionItem OR
       has_model_ssim:Image OR has_model_ssim:Report OR has_model_ssim:ThesisOrDissertation OR has_model_ssim:TimeBasedMedia OR has_model_ssim:GenericWork OR has_model_ssim:BookChapter OR
       has_model_ssim:Media OR has_model_ssim:Presentation OR has_model_ssim:Uncategorized OR has_model_ssim:TextWork OR has_model_ssim:NewsClipping OR has_model_ssim:ArticleWork OR
      has_model_ssim:BookWork OR has_model_ssim:ImageWork OR has_model_ssim:ThesisOrDissertationWork)'.freeze

    begin
      works_for_update = ActiveFedora::Base.where("NOT collection_names_sim: [* TO *] OR #{work_list} AND member_of_collection_ids_ssim: [* TO *]")
      works_for_update .each_slice(150) do |batch|
      #by calling save we trigger the before_save callback in app/models/ubiquity/concerns/multiple_modules.rb
        batch.each do |work|
          puts "updating #{work.try(:title).try(:first)}"
          collection_names = work.member_of_collections.map {|collection| collection.try(:title).try(:first)}
          work.collection_id = work.member_of_collection_ids.to_a
          work.collection_names = collection_names
          work.save(validate: false)
          sleep 2
        end
      end

    rescue ActiveFedora::AssociationTypeMismatch, ActiveFedora::RecordInvalid, Ldp::Gone, RSolr::Error::Http, RSolr::Error::ConnectionRefused  => e
      puts "error saving #{e}"
    end

  end

#run with
#rake ubiquity_resave_records:all_exempt_collections['sandbox.repo-test.ubiquity.press']
 desc "Update data by resaving records except collection for existing works"
  task :all_exempt_collections, [:name] => :environment do |task, tenant|

    #These are the names of the existing work type in UbiquityPress's Hyku
    model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork]
    AccountElevator.switch!("#{tenant[:name]}")
    begin
      model_class.each do |model|
        #We fetching an instance of the models and then getting the value in the creator field
        model.find_each do |model_instance|
          puts "model_id in in re-saving record rake task: #{model} : #{model_instance.id}"
         #by calling save we trigger the before_save callback in app/models/ubiquity/concerns/multiple_modules.rb
          model_instance.save(validate: false)
          sleep 2
        end
      end
    rescue ActiveFedora::AssociationTypeMismatch, ActiveFedora::RecordInvalid, Ldp::Gone, RSolr::Error::Http, RSolr::Error::ConnectionRefused  => e
      puts "error saving #{e}"
    end
  end

  #run with
  #rake "ubiquity_resave_records:update_specific_model[sandbox.repo-test.ubiquity.press,  generic_work]"
  desc "Update data by resaving records for a specific work type"
  task :update_specific_model, [:tenant_name, :model_name] => :environment do |task, args|
    tenant_name = args[:tenant_name]
    puts "tenant_cname in update specific model rake task: #{tenant_name}"
    AccountElevator.switch!(tenant_name)
    model = args[:model_name]
    model_class = model.to_s.classify.constantize
    puts "model_name  in update specific model rake task: #{model_class}"

    model_class.find_each do |model_instance|
      puts "model_id in in update specific model rake task:  #{model_instance.id}"
       #by calling save we trigger the before_save callback in app/models/ubiquity/concerns/multiple_modules.rb
      model_instance.save(validate: false)
      sleep 2
    end
  end

#run with
# rake 'ubiquity_resave_records:where_metatdata_field_not_empty[library.localhost, editor_tesim]'
#
 desc "Update data by resaving records for existing works where the goven field is not empty"
  task :where_metatdata_field_not_empty,  [:tenant_name, :solr_field_name] => :environment do |task, args|
    tenant_name = args[:tenant_name]
    puts "tenant_cname in update specific model rake task: #{tenant_name}"
    AccountElevator.switch!(tenant_name)
    field_name = args[:solr_field_name]
    #fetch all records where this field is not empty
    records = ActiveFedora::Base.where("#{field_name}:[* TO *]")

    puts "#{records.size } records found where #{field_name} is not empty"

    records.each do |model_instance|
      puts "updating #{field_name} in where_metatdata_field_not_empty rake task for: #{model_instance.class}  #{model_instance.id}"
       #by calling save we trigger the before_save callback in app/models/ubiquity/concerns/multiple_modules.rb
      model_instance.save(validate: false)
      sleep 2
    end
  end


end
