FactoryGirl.define do
  factory :dataset do
    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |dataset, evaluator|
      dataset.apply_depositor_metadata(evaluator.user)
    end
  end
end
