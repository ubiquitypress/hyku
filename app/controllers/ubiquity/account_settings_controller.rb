class Ubiquity::AccountSettingsController < AdminController
   layout 'dashboard'

   before_action :set_account

  def index
  end

  def create
  end

  def edit
  end

  def update
    @account.update(account_params)
    redirect_to admin_account_settings_path
  end



  private

  def set_account
    @account = current_account
  end

  def account_params
    params.require(:account).permit(:settings => [:contact_email])
  end

end
