
  # Provide select options for the copyright status (edm:rights) field
  #class RightsStatementService < QaSelectService
  #
class InstitutionService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
     super('institution')
  end
end

