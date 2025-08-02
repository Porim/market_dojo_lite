FactoryBot.define do
  factory :rfq do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    deadline { 1.week.from_now }
    status { "draft" }
    association :user, factory: [ :user, :buyer ]

    trait :published do
      status { "published" }
    end

    trait :closed do
      status { "closed" }
    end

    trait :with_quotes do
      after(:create) do |rfq|
        create_list(:quote, 3, rfq: rfq)
      end
    end
  end
end
