class Auction < ApplicationRecord
  belongs_to :rfq
  has_many :bids, dependent: :destroy

  # Validations
  validates :status, presence: true, inclusion: { in: %w[pending active completed] }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :current_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(status: "active").where("start_time <= ? AND end_time > ?", Time.current, Time.current) }
  scope :upcoming, -> { where(status: "pending").where("start_time > ?", Time.current) }
  scope :completed, -> { where(status: "completed") }

  # Callbacks
  before_validation :set_default_status, on: :create

  # Methods
  def active?
    status == "active" && Time.current.between?(start_time, end_time)
  end

  def time_remaining
    return 0 unless active?
    (end_time - Time.current).to_i
  end

  private

  def set_default_status
    self.status ||= "pending"
  end
end
