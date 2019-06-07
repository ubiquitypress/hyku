#class RightsStatementService < QaSelectService

class CurrentHeInstitutionService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
     super('current_he_institution')
  end
end
