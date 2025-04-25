FactoryBot.define do
  factory :post_image do
    association :post
    image { 'test_image.jpg' }
  end
end
