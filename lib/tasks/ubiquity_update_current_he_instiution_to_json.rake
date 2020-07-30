# Run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
# for example if the tenant cname is 'sandbox.repo-test.ubiquity.press' run as shown below
# rake ubiquity_update_current_he_institution_to_json:update['sandbox.repo-test.ubiquity.press']



namespace :ubiquity_update_current_he_institution_to_json do
  desc "Resave all thesis and dissertation works with updated json field"

  task :update, [:name] => :environment do |task, tenant|
    hash = YAML.load(File.read('config/authorities/current_he_institution.yml'))
    terms = hash.with_indifferent_access.fetch(:terms, [])
    options = terms.map do |res|
      { id: res[:id] , isni: res[:isni], ror: res[:ror] }
    end
    cname = tenant[:name]
    AccountElevator.switch!("#{cname}")
    works = ActiveFedora::Base.where("NOT system_modified_dtsi:[NOW-1DAY/DAY TO NOW] AND current_he_institution_tesim: [* TO *] OR has_model_ssim:ThesisOrDissertation")
    puts "Found #{works.count} works"
    puts works.inspect
    works.each do |work|
      puts work.inspect
      next if work.current_he_institution[0].nil? ||  work.current_he_institution[0].empty?
      next if Ubiquity::JsonValidator.valid_json?(work.current_he_institution.first)
      puts "Running for #{work.title.inspect}"
      current_data = work.current_he_institution[0] ||  work.current_he_institution
      options_hash = options.find { |he| he[:id] == current_data }
      new_data =  [{"current_he_institution_name": "#{options_hash[:id]}", "current_he_institution_isni": "#{options_hash[:isni]}", "current_he_institution_ror": "#{options_hash[:ror]}"}]
      work.current_he_institution = [new_data.to_json]
      work.save(validate: false)
    end
  end
end
