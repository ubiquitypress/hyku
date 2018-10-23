class FunderService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('funder')
  end
end
