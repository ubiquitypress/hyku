FactoryGirl.define do
  json_data = ENV['TENANTS_WORK_SETTINGS']
  data = JSON.parse(json_data) if json_data.present? && json_data.class == String
  email_format = data['email_format'][0]

  factory :base_user, class: User do
    sequence(:email) { |_n| "email-#{srand}#{email_format.present? ? email_format : '@test.com'}" }
    password 'a password'
    password_confirmation 'a password'

    factory :user do
      after(:create) { |user| user.remove_role(:admin) }
    end

    factory :admin do
      after(:create) { |user| user.add_role(:admin) }
    end

    factory :superadmin do
      after(:create) { |user| user.add_role(:superadmin) }
    end

    factory :invited_user do
      after(:create, &:invite!)
    end
  end
end
