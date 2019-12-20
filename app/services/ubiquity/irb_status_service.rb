class IrbStatusService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('irb_status')
  end
end
