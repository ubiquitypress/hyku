#class RightsStatementService < QaSelectService

class QualificationNameService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
     super('qualification_name')
  end
end
