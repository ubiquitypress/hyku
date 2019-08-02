Rails.application.routes.draw do

  concern :oai_provider, BlacklightOaiProvider::Routes.new

  namespace :ubiquity do
    resources :external_services
  end
  if Settings.multitenancy.enabled
    constraints host: Account.admin_host do
      get '/account/sign_up' => 'account_sign_up#new', as: 'new_sign_up'
      post '/account/sign_up' => 'account_sign_up#create'
      get '/', to: 'splash#shared_layer'
      # pending https://github.com/projecthydra-labs/hyrax/issues/376
      get '/dashboard', to: 'splash#index'

      namespace :proprietor do
        resources :accounts
      end
    end
  end

  get 'status', to: 'status#index'

  resources :available_ubiquity_titles, only: [:check, :call_datasite] do
      collection do
        post :check
        post :call_datasite
      end
  end

  scope :module => "ubiquity" do
    #resources :datacite, only: [:create, :index]
  end


  post '/external_services/generate_doi', to: 'ubiquity/external_services#generate_doi', as: 'external_services_generate_doi'

  scope :module => "ubiquity" do
    resources :account_settings, path: "/admin/account_settings", controller: 'account_settings', as: 'admin_account_settings'
  end

  # Fail Uploads Controller route
  get '/fail_uploads/delete_file' => 'ubiquity/fail_uploads#delete_file'
  post '/fail_uploads/download_file' => 'ubiquity/fail_uploads#download_file'

  # Citation download format
  post '/citation_exports/export_to_rif' => 'ubiquity/citation_exports#export_to_rif'

  mount BrowseEverything::Engine => '/browse'
  resource :site, only: [:update] do
    resources :roles, only: [:index, :update]
    resource :labels, only: [:edit, :update]
  end

  root 'hyrax/homepage#index'

  devise_for :users, controllers: { invitations: 'hyku/invitations', registrations: 'hyku/registrations' }

  devise_scope :user do
     get 'admin', to: 'ubiquity/superadmin_sessions#new', as: 'new_superadmin_sessions'
     post 'admin', to: 'ubiquity/superadmin_sessions#create', as: 'superadmin_sessions'
     get '/admin/signout', to: 'ubiquity/superadmin_sessions#destroy', as:  'destroy_superadmin_session'
  end

  mount Qa::Engine => '/authorities'

  mount Blacklight::Engine => '/'
  mount Hyrax::Engine, at: '/'

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new

  curation_concerns_basic_routes do
    member do
      get :manifest
    end
  end

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

    concerns :searchable
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  namespace :admin do
    resources :exports, only: [:index] do
      collection do
        get :export_database
        get :export_remap_model
        get :export_model
      end
  end

   resource :account, only: [:edit, :update]
    resources :users, only: [:destroy]
    resources :groups do
      member do
        get :remove
      end

      resources :users, only: [:index], controller: 'group_users' do
        collection do
          post :add
          delete :remove
        end
      end
    end
  end

  mount Riiif::Engine => '/images', as: 'riiif'

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
 #standalone authentication for sidekiq not using devise or sessions
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end if Rails.env.production?

  mount Sidekiq::Web => '/sidekiq'

end
