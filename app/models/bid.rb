class Bid < ApplicationRecord
  belongs_to :auction
  belongs_to :user

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :amount_must_be_lower_than_current

  # Scopes
  scope :by_amount, -> { order(amount: :asc) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :update_auction_current_price
  after_create_commit :broadcast_bid

  private

  def amount_must_be_lower_than_current
    return unless auction && auction.current_price

    if amount >= auction.current_price
      errors.add(:amount, "must be lower than current price (#{auction.current_price})")
    end
  end

  def update_auction_current_price
    auction.update(current_price: amount)
  end

  def broadcast_bid
    AuctionChannel.broadcast_to(
      auction,
      {
        action: "new_bid",
        current_price: auction.current_price,
        bid: {
          id: id,
          amount: amount,
          user: user.company_name,
          created_at: created_at.strftime("%I:%M:%S %p")
        }
      }
    )
  end
end
