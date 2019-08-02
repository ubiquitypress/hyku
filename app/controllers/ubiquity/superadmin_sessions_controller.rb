class Ubiquity::SuperadminSessionsController < Devise::SessionsController

  def new
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
