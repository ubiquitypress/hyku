class Ubiquity::DOIWorkFormComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end

  def render?
    Flipflop.doi_support?
  end
end
