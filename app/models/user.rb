class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :rfqs, dependent: :destroy
  has_many :quotes, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_one :email_preference, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[buyer supplier] }
  validates :company_name, presence: true

  # Scopes
  scope :buyers, -> { where(role: "buyer") }
  scope :suppliers, -> { where(role: "supplier") }

  # Methods
  def buyer?
    role == "buyer"
  end

  def supplier?
    role == "supplier"
  end

  # Callbacks
  after_create :create_email_preferences
  before_create :generate_api_token

  # API methods
  def regenerate_api_token!
    generate_api_token
    save!
  end

  private

  def create_email_preferences
    EmailPreference.create(user: self)
  end

  def generate_api_token
    self.api_token = SecureRandom.hex(32)
  end
end
