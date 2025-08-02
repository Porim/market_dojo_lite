class EmailPreference < ApplicationRecord
  belongs_to :user

  # Default all preferences to true
  after_initialize :set_defaults

  private

  def set_defaults
    self.rfq_created = true if rfq_created.nil?
    self.quote_received = true if quote_received.nil?
    self.auction_started = true if auction_started.nil?
    self.auction_ended = true if auction_ended.nil?
    self.quote_accepted = true if quote_accepted.nil?
  end
end
