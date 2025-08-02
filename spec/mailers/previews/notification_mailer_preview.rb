# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def rfq_created
    rfq = Rfq.first || FactoryBot.create(:rfq)
    supplier = User.suppliers.first || FactoryBot.create(:user, :supplier)
    NotificationMailer.rfq_created(rfq, supplier)
  end

  def quote_received
    quote = Quote.first || FactoryBot.create(:quote)
    NotificationMailer.quote_received(quote)
  end

  def auction_started
    auction = Auction.first || FactoryBot.create(:auction)
    participant = User.suppliers.first || FactoryBot.create(:user, :supplier)
    NotificationMailer.auction_started(auction, participant)
  end

  def auction_ended
    auction = Auction.first || FactoryBot.create(:auction)
    participant = User.suppliers.first || FactoryBot.create(:user, :supplier)
    NotificationMailer.auction_ended(auction, participant)
  end

  def quote_accepted
    quote = Quote.first || FactoryBot.create(:quote)
    NotificationMailer.quote_accepted(quote)
  end
end
