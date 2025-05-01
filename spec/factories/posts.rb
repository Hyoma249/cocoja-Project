FactoryBot.define do
  factory :post do
    association :user
    association :prefecture
    content { Faker::Lorem.paragraph }
  end
end
