module Ubiquity::ImporterLinkHelper
  
  def importer_link_based_on_environment
    if current_account.cname  == 'sandbox.repo-test.ubiquity.press' || current_account.cname.split('.').include?('localhost')
      'https://importer.repo-test.ubiquity.press'
    else
      'https://importer.pacific.us.ubiquityrepository.website'
    end
  end
end
