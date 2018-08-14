class CreatorNameTypeService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('creator_name_type')
  end
end