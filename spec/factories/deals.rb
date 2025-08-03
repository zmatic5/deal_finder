FactoryBot.define do
  factory :deal do
    sequence(:title) { |n| "Amazing Deal ##{n}" }
    description { "This is a fantastic deal you can't miss." }
    original_price { 100.0 }
    discount_price { 50.0 }
    discount_percentage { 50 }
    category { "Food & Drink" }
    merchant_name { "The Deal Shop" }
    average_rating { 4.5 }
    quantity_sold { 150 }
    latitude { 40.7128 }
    longitude { -74.0060 }
  end
end
