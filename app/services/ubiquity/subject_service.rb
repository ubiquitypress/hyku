class SubjectService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super("subject.#{I18n.locale}")
  end
end
