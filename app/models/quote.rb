class Quote < ApplicationRecord
  belongs_to :rfq
  belongs_to :user

  # Validations
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :user_id, uniqueness: { scope: :rfq_id, message: "has already submitted a quote for this RFQ" }

  # Scopes
  scope :by_price, -> { order(price: :asc) }
end
