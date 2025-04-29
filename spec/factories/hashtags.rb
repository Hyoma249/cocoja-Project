FactoryBot.define do
  factory :hashtag do
    sequence(:name) { |n| "hashtag#{n}" }
  end
end
