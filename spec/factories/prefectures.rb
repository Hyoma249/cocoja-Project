# spec/factories/prefectures.rb
FactoryBot.define do
  factory :prefecture do
    sequence(:name) { |n| "都道府県#{n}" }
  end
end
