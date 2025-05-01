# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    username { Faker::Internet.unique.username(specifier: 1..20) }
    uid { Faker::Alphanumeric.unique.alphanumeric(number: 10) }
    bio { Faker::Lorem.paragraph_by_chars(number: 160) }

    # 確実に有効なデータを生成するために、不正な文字を除去
    after(:build) do |user|
      user.username = user.username.gsub(/[^a-zA-Z0-9]/, '')
      user.uid = user.uid.gsub(/[^a-zA-Z0-9]/, '')
    end
  end
end
