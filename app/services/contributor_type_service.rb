class ContributorTypeService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('contributor_type')
  end
end