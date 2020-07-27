#class RightsStatementService < QaSelectService

class CurrentHeInstitutionService < Hyrax::QaSelectService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('current_he_institution')

  def self.select_active_options
    all_options_hash.map { |e| [e[:label], e[:id]] }
  end

  def self.select_active_options_isni
    all_options_hash.map { |e| e[:isni] }
  end

  def self.select_active_options_ror
    all_options_hash.map { |e| e[:ror] }
  end

  def self.subauthority_filename
    File.join(Qa::Authorities::Local.subauthorities_path, "current_he_institution.yml")
  end

  def self.terms
    subauthority_hash = YAML.load(File.read(subauthority_filename))
    terms = subauthority_hash.with_indifferent_access.fetch(:terms, [])
  end

  def self.all_options_hash
    terms.map do |res|
      { id: res[:id], label: res[:term], isni: res[:isni], ror: res[:ror], active: res.fetch(:active, true) }.with_indifferent_access
    end
  end

end
