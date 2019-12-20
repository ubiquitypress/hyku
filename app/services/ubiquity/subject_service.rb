class SubjectService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('subject')
  end
end
