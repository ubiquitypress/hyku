## rake ubiquity_remove_unused_resource_type:update['sandbox.repo-test.ubiquity.press']

namespace :ubiquity_remove_unused_resource_type do
  desc "removing unwanted resource type from GenericWork. "

  task :update, [:name] => :environment do |task, tenant|

    AccountElevator.switch!("#{tenant[:name]}")
    resource_types = ["GenericWork Technical documentation", "GenericWork Sound", "GenericWork Software",
        "GenericWork Dissertation", "GenericWork Thesis (doctoral)", "GenericWork Exhibition"]
    generic_works = GenericWork.where(resource_type: resource_types)
    puts "#{generic_works.size.inspect} generic_works found!"
    generic_works.each do |work|
      work.resource_type  = []
      work.save
    end

  end
end
