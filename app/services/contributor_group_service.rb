class ContributorGroupService < Hyrax::QaSelectService
  def initialize(_authority_name = nil)
    super('contributor_group')
  end

=begin
  def self.label(id)
    self.class.authority.find(id).fetch('term')
  end
=end

end