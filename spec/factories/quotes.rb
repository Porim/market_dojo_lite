FactoryBot.define do
  factory :quote do
    price { Faker::Commerce.price(range: 100..10000) }
    notes { Faker::Lorem.paragraph }
    association :rfq
    association :user, factory: [ :user, :supplier ]
  end
end
