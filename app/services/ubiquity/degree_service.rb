class DegreeService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('degree')
  end
end
