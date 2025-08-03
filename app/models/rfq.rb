class Rfq < ApplicationRecord
  belongs_to :user
  has_many :quotes, dependent: :destroy
  has_one :auction, dependent: :destroy
  has_many_attached :documents

  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft published closed] }
  validates :deadline, presence: true
  validate :acceptable_documents

  # Scopes
  scope :draft, -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }
  scope :closed, -> { where(status: "closed") }
  scope :active, -> { published.where("deadline > ?", Time.current) }

  # Callbacks
  before_validation :set_default_status, on: :create

  # Instance methods
  def published?
    status == "published"
  end

  def draft?
    status == "draft"
  end

  def closed?
    status == "closed"
  end

  def active?
    published? && deadline > Time.current
  end

  private

  def set_default_status
    self.status ||= "draft"
  end

  def acceptable_documents
    return unless documents.attached?

    documents.each do |document|
      unless document.content_type.in?(%w[application/pdf
                                          application/msword
                                          application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                          application/vnd.ms-excel
                                          application/vnd.openxmlformats-officedocument.spreadsheetml.sheet])
        errors.add(:documents, "must be PDF, DOC, DOCX, XLS, or XLSX")
      end

      if document.byte_size > 10.megabytes
        errors.add(:documents, "#{document.filename} is too large (maximum is 10MB)")
      end
    end
  end
end
