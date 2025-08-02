FactoryBot.define do
  factory :auction do
    status { "pending" }
    start_time { 1.hour.from_now }
    end_time { 2.hours.from_now }
    current_price { nil }
    association :rfq

    trait :active do
      status { "active" }
      start_time { 1.hour.ago }
      end_time { 1.hour.from_now }
    end

    trait :completed do
      status { "completed" }
      start_time { 2.hours.ago }
      end_time { 1.hour.ago }
    end
  end
end