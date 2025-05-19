FactoryBot.define do
  factory :weekly_ranking do
    association :prefecture
    year { Time.current.year }
    week { Time.current.strftime('%U').to_i }
    rank { rand(1..47) }
    points { rand(0..1000) }
  end
end
