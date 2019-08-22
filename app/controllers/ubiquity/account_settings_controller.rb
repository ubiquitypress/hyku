class Ubiquity::AccountSettingsController < AdminController
   layout 'dashboard'

   before_action :set_account

  def index
  end

  def edit
    respond_to do |format|
      format.js {render template: "ubiquity/account_settings/settings/#{params[:partial_name]}.js.erb"}
      format.html
    end
  end

  def update
    @account.update(account_params)
    redirect_to admin_account_settings_path
  end

  def update_single
    submitted_hash = account_params.to_h['settings']
    hash_key = submitted_hash.keys.first
    if hash_key.present?
      #update only the hash key without overriding other content in the original hash
      @account.settings[hash_key] = submitted_hash[hash_key]
      #removes nil keys in the hash
      @account.settings.compact
      @account.save
    end
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
