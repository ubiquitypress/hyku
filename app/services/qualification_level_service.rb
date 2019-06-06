#class RightsStatementService < QaSelectService

class QualificationLevelService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
     super('qualification_level')
  end
end
