class Ubiquity::SuperadminSessionsController < Devise::SessionsController

  def new
    #self.resource = resource_class.new(sign_in_params)
    super

  end

  def create
    session[:ubiquity_super] = 'ubiquity_super'
    super
  end

  def destroy
    session.delete(:ubiquity_super)
    super
  end

end
