## rake ubiquity_reindex_shared_search:update['sandbox.repo-test.ubiquity.press']
#  rake ubiquity_reindex_shared_search:update["library.localhost"]
#rake ubiquity_reindex_shared_search:destroy["library.localhost"]

namespace :ubiquity_reindex_shared_search do
  desc "create the root account or parent or main tenant that can have other tenants. "

  task :update, [:name] => :environment do |task, tenant|
    cname = tenant[:name]
    account = Account.where(cname: cname).first
    parent_cname = account.parent.cname
    #These are the names of the existing work type in UbiquityPress's Hyku
    model_class = [Collection, Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork, FileSet]
    AccountElevator.switch!(cname)
    #ActiveFedora::Base.reindex_everything
    model_class.each do |model|
      model.all.each_slice(95)  do |batch|
        batch_of_works = batch.map(&:to_solr)
        if account.parent_id.present?
          Ubiquity::SharedIndexSolrServiceWrapper.new(batch_of_works, 'add', parent_cname).update
         end
         AccountElevator.switch!(cname)
        end
      end
    end

    task :update_specific_model, [:tenant_name, :model_name] => :environment do |task, args|
      cname = args[:tenant_name]
      account = Account.where(cname: cname).first
      parent_cname = account.parent.cname

      AccountElevator.switch!(cname)
      model = args[:model_name]
      model_class = model.to_s.classify.constantize
      puts "In reindex_shared_search rake adding #{model_class}: to shared search"

      model_class.all.each_slice(95) do |batch|
        batch_of_works = batch.map(&:to_solr)
        if account.parent_id.present?
          Ubiquity::SharedIndexSolrServiceWrapper.new(batch_of_works, 'add', parent_cname).update
        end
        AccountElevator.switch!(cname)
      end
    end

    task :destroy, [:name] => :environment do |task, tenant|
      cname = tenant[:name]
      account = Account.where(cname: cname).first
      parent_cname = account.parent.cname
      #These are the names of the existing work type in UbiquityPress's Hyku
      model_class = [Collection, Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork, FileSet]
      AccountElevator.switch!(cname)
      #ActiveFedora::Base.reindex_everything
      model_class .each do |model|
        model.all.each  do |batch|
          if account.parent_id.present?
            Ubiquity::SharedIndexSolrServiceWrapper.new(batch.to_solr, 'remove', parent_cname).update
           end
           AccountElevator.switch!(cname)
          end
        end
      end

      task :destroy_specific_model, [:tenant_name, :model_name] => :environment do |task, args|
        cname = args[:tenant_name]
        account = Account.where(cname: cname).first
        parent_cname = account.parent.cname

        AccountElevator.switch!(cname)
        model = args[:model_name]
        model_class = model.to_s.classify.constantize
        puts "In reindex_shared_search rake adding #{model_class}: to shared search"

        model_class.all.each do |batch|
          if account.parent_id.present?
            Ubiquity::SharedIndexSolrServiceWrapper.new(batch.to_solr, 'remove', parent_cname).update
          end
          AccountElevator.switch!(cname)
        end
      end

end
