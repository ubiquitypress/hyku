require_relative 'boot'

require 'rails/all'
require 'i18n/debug' if ENV['I18N_DEBUG']

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hyku
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Gzip all responses.  We probably could do this in an upstream proxy, but
    # configuring Nginx on Elastic Beanstalk is a pain.
    config.middleware.use Rack::Deflater

    # The locale is set by a query parameter, so if it's not found render 404
    config.action_dispatch.rescue_responses.merge!(
      "I18n::InvalidLocale" => :not_found
    )

    if defined? ActiveElasticJob
      Rails.application.configure do
        config.active_elastic_job.process_jobs = Settings.worker == 'true'
        config.active_elastic_job.aws_credentials = lambda { Aws::InstanceProfileCredentials.new }
        config.active_elastic_job.secret_key_base = Rails.application.secrets[:secret_key_base]
      end
    end

    config.to_prepare do
      # Do dependency injection after the classes have been loaded.
      # Before moving this here (from an initializer) Devise was raising invalid
      # authenticity token errors.
      Hyrax::Admin::AppearancesController.form_class = AppearanceForm
      Hyrax::FileSetsController.show_presenter = Hyku::FileSetPresenter
      Dir.glob(Rails.root + "app/decorators/**/*_decorator.rb").each do |c|
        require_dependency(c)
      end
      Hyrax::DownloadsController.include ::Hyrax::DownloadsControllerDecorator
      #added by UbiquityPress to allow us render image when available without rendering default_icon
      Hyrax::CollectionPresenter.class_eval {delegate :thumbnail_id, to: :solr_document}
      #Removes subject from collection click additional fields to see subject is gone
      Hyrax::Forms::CollectionForm.prepend(::Ubiquity::CollectionFormBehaviour)
      Hyrax::Forms::BatchEditForm.prepend(::Ubiquity::AdditionalBatchEdit)
      Hyrax::FileSetDerivativesService.prepend(::Ubiquity::FilesetDerivativesServiceOverride)
      Hyrax::ContactFormController.prepend(::Ubiquity::ContactFormControllerOverride)
      Hyrax::UploadsController.prepend(::Ubiquity::UploadsControllerOverride)
      # Loading module to initiateCall back for the Hyrax::UploadedFile model for file_status attribute
      Hyrax::UploadedFile.include(::Ubiquity::FileUploadCallback)
      # Modifying the default limit of the per page in the collection list to 100
      Hyrax::CollectionMemberSearchBuilder.include(::Ubiquity::CollectionListPerPage)
      Account.class_eval {include Ubiquity::AccountSelfJoinAssociation}
      Hyrax::FileSetPresenter.class_eval {delegate :visibility, to: :solr_document}
    end

    config.before_initialize do
      if defined? ActiveElasticJob
        Rails.application.configure do
          config.active_elastic_job.process_jobs = Settings.worker == 'true'
          config.active_elastic_job.aws_credentials = lambda { Aws::InstanceProfileCredentials.new }
          config.active_elastic_job.secret_key_base = Rails.application.secrets[:secret_key_base]
        end
      end
    end

    #Everything below added ubiquity
    Raven.configure do |config|
      if ENV['SENTRY_DSN']
        config.dsn = ENV['SENTRY_DSN']
      end
    end

    config.eager_load_paths << Rails.root.join('lib')

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      if env_file.present?
        YAML.load(File.open(env_file)).try(:each) do |key, value|
          ENV[key.to_s] = value
        end if File.exists?(env_file)
      end
    end

  end
end
