FactoryBot.define do
  factory :email_preference do
    user
    rfq_created { true }
    quote_received { true }
    auction_started { true }
    auction_ended { true }
    quote_accepted { true }
  end
end
