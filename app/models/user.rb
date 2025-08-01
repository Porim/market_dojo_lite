class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :rfqs, dependent: :destroy
  has_many :quotes, dependent: :destroy
  has_many :bids, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[buyer supplier] }
  validates :company_name, presence: true

  # Scopes
  scope :buyers, -> { where(role: 'buyer') }
  scope :suppliers, -> { where(role: 'supplier') }

  # Methods
  def buyer?
    role == 'buyer'
  end

  def supplier?
    role == 'supplier'
  end
end
