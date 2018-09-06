class RelatedIdentifierTypeService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('related_identifier_type')
  end
end