class Rfq < ApplicationRecord
  belongs_to :user
  has_many :quotes, dependent: :destroy
  has_one :auction, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft published closed] }
  validates :deadline, presence: true

  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :active, -> { published.where('deadline > ?', Time.current) }

  # Callbacks
  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= 'draft'
  end
end
