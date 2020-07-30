#rake ubiquity_update_funder_to_json:update['sandbox.repo-test.ubiquity.press']
#

namespace :ubiquity_update_funder_to_json do

  desc "Convert records in funders field to JSON"
  task :update, [:tenant] => :environment do |task, args|

    AccountElevator.switch!("#{args[:tenant]}")

    model_class = get_work_list(args[:tenant]).join(',')
    works = ActiveFedora::Base.where("NOT system_modified_dtsi:[NOW-1DAY/DAY TO NOW] AND funder_tesim: [* TO *] OR has_model_ssim:#{model_class}")

    puts "Total #{works.size} for funder resave"

    works.each do |work|
      new_funder(work)
      sleep 1
    end



  end

  def new_funder(work)
    if !Ubiquity::JsonValidator.valid_json?(work.funder.first)
      puts "#{work.title} has #{work.funder.size} funders for data change"
      remapped_funder = work.funder.map.with_index do |item, idx|
        {"funder_name": item, "funder_position" => idx}
      end.try(:to_json)

      puts "remapper funder  #{remapped_funder}"
      work.funder = [remapped_funder]

      #by calling save we trigger the before_save callback in app/models/ubiquity/concerns/multiple_modules.rb
      work.save(validate: false)
    end

    rescue ActiveFedora::AssociationTypeMismatch, ActiveFedora::RecordInvalid, Ldp::Gone, RSolr::Error::Http, RSolr::Error::ConnectionRefused  => e
    puts "error saving #{e}"
  end


  def get_work_list(tenant_name)

    if Ubiquity::ParseTenantWorkSettings.respond_to?(:get_per_account_settings_value_from_tenant_settings)
      parser_class = Ubiquity::ParseTenantWorkSettings.new(tenant_name)
      work_list = parser_class.get_per_account_settings_value_from_tenant_settings("work_type_list")
      work_types_array = work_list.presence && work_list.split(',')
      list = work_types_array.present? ? work_types_array.map {|i| i.classify.constantize} : Hyrax.config.curation_concerns
      puts "using work_type_list from settings #{list}"
      list
    else
      list =  Hyrax.config.curation_concerns
      puts "using default work_type_list  #{list}"
      list
    end

  end

end
