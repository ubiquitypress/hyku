# overrides hyrax/app/services/hyrax/resource_types_service.rb

module ResourceTypesService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('resource_types')

  def self.template_fields(model_class)
    authority.all.select { |e| e[:id].split.first == model_class.to_s }
  end

  def self.select_template_options(model_class)
    template_fields(model_class).map { |t| [t[:label], t[:id]] }
  end

  def self.label(id)
    authority.find(id).fetch('term')
  end

  def self.select_default(model_class)
    default = template_fields(model_class).select { |e| e[:id].split[1] == 'default' }
    default.first["id"] if default.present?
  end
end
