FactoryBot.define do
  factory :recipe do
    title { Faker::Food.dish }
    cook_time { rand(5..120) }
    prep_time { rand(1..60) }
    ratings { rand.round(2) }
    cuisine { Faker::Food.ethnic_category }
    category { Faker::Food.dish }
    author { Faker::Name.name }
    image { Faker::Internet.url }
    ingredients_list { ["2 eggs", "1 cup flour", "1 cup milk"] }
  end
end
