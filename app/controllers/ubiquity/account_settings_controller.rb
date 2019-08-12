class Ubiquity::AccountSettingsController < AdminController
   layout 'dashboard'

   before_action :set_account

  def index
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
    params.require(:account).permit(:settings => [:contact_email, :index_record_to_shared_search, weekly_email_list: [],
                                   monthly_email_list: [], yearly_email_list: []])
  end

end
