class User < ApplicationRecord
  # Includes lib/rolify from the rolify gem
  rolify
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  attr_accessible :email, :password, :password_confirmation if Blacklight::Utils.needs_attr_accessible?
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :invitable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :add_default_roles

  # allow omniauth (including shibboleth) logins
  #   this will create a local user based on an omniauth/shib login
  #   if they haven't logged in before
  def self.from_omniauth(auth)
    Rails.logger.debug "auth = #{auth.inspect}"
    # Uncomment the debugger above to capture what a shib auth object looks like for testing
    user = where(provider: auth[:provider], uid: auth[:uid]).first_or_create
    user.display_name = auth[:name]
    user.uid = auth[:uid]
    user.email = auth[:uid]
    user.password = Devise.friendly_token[0,20]
    user.save
    user
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier.
  def to_s
    email
  end

  def site_roles
    roles.site
  end

  def site_roles=(roles)
    roles.reject!(&:blank?)

    existing_roles = site_roles.pluck(:name)
    new_roles = roles - existing_roles
    removed_roles = existing_roles - roles

    new_roles.each do |r|
      add_role r, Site.instance
    end

    removed_roles.each do |r|
      remove_role r, Site.instance
    end
  end

  def groups
    return ['admin'] if has_role?(:admin, Site.instance)
    []
  end

  private

    def add_default_roles
      add_role :admin, Site.instance unless self.class.any? || Account.global_tenant?
    end
end
