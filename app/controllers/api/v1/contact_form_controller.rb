class API::V1::ContactFormController < ActionController::Base

  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods

  def create
    hash =  {category: params[:category], name: params[:name], email: params[:email], subject: params[:subject],
           message: params[:message], contact_method: params[:contact_method]}
     @contact_form =  Hyrax::ContactForm.new(hash)
     headers = {subject: "#{Hyrax.config.subject_prefix} #{ @contact_form.subject}", to: Hyrax.config.contact_email,
                 from: @contact_form.email}
     @contact_form.headers = headers
     if @contact_form.spam?
       render json: {code: 422,  status: :spam_not_sent}
     elsif @contact_form.valid?
       Hyrax::ContactMailer.contact(@contact_form, @tenant).deliver_now
       render json: {code: 201,  status: :created}
     else
       render json: "Your contact form is missing one of the following compulsory fields :name, :category, :email, :subject, :message"
     end
  end

end
