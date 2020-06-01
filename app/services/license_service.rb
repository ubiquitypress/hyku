# overrides hyrax/app/services/hyrax/resource_types_service.rb

module LicenseService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('licenses')

  def self.label(id)
    id = authority.find(id)
    id.empty? ? 'Unkown' : id.fetch('term')
  end

end
