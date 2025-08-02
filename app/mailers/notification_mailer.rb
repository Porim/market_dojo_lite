class NotificationMailer < ApplicationMailer
  def rfq_created(rfq, supplier)
    @rfq = rfq
    @supplier = supplier
    @buyer = rfq.user

    mail(
      to: @supplier.email,
      subject: "New RFQ: #{@rfq.title}"
    )
  end

  def quote_received(quote)
    @quote = quote
    @rfq = quote.rfq
    @supplier = quote.user
    @buyer = @rfq.user

    mail(
      to: @buyer.email,
      subject: "New quote received for: #{@rfq.title}"
    )
  end

  def auction_started(auction, participant)
    @auction = auction
    @rfq = auction.rfq
    @participant = participant

    mail(
      to: @participant.email,
      subject: "Auction started: #{@rfq.title}"
    )
  end

  def auction_ended(auction, participant)
    @auction = auction
    @rfq = auction.rfq
    @participant = participant
    @winner = auction.bids.by_amount.first&.user

    mail(
      to: @participant.email,
      subject: "Auction ended: #{@rfq.title}"
    )
  end

  def quote_accepted(quote)
    @quote = quote
    @rfq = quote.rfq
    @supplier = quote.user
    @buyer = @rfq.user

    mail(
      to: @supplier.email,
      subject: "Your quote has been accepted for: #{@rfq.title}"
    )
  end
end
