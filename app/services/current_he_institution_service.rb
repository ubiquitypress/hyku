#class RightsStatementService < QaSelectService

class CurrentHeInstitutionService < Hyrax::QaSelectService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('current_he_institution')

  def self.select_active_options
    active_elements.map { |e| [e[:label], e[:id]] }
  end

  def self.active_elements
    authority.all.select { |e| e.fetch('active') }
  end
end
