# spec/factories/prefectures.rb
FactoryBot.define do
  factory :prefecture do
    name { Faker::Address.unique.state }
    description { Faker::Lorem.paragraph }
# その他の属性を追加
  end
end
