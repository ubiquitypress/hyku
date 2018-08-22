# overrides hyrax/app/services/hyrax/resource_types_service.rb

module ResourceTypesService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('resource_types')

  def self.select_template_options(model_class)
    template_fields = authority.all.select { |e| e[:id].split.first == model_class.to_s }
    template_fields.map { |t| [t[:label], t[:id]] }
  end

  def self.label(id)
    authority.find(id).fetch('term')
  end
end
