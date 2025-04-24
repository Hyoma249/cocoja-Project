FactoryBot.define do
  factory :vote do
    association :user
    association :post
    points { rand(1..5) }
  end
end
