class AnalyticsController < ApplicationController
  before_action :require_buyer!

  def index
    # RFQ Analytics
    @rfqs_by_status = current_user.rfqs.group(:status).count
    @rfqs_by_month = current_user.rfqs
                        .group_by_month(:created_at, last: 6, current: true)
                        .count

    # Quote Analytics
    @avg_quotes_per_rfq = current_user.rfqs.published
                            .joins(:quotes)
                            .group(:id)
                            .count
                            .values
                            .sum.to_f / current_user.rfqs.published.count.to_f

    @quotes_by_rfq = current_user.rfqs.published
                        .joins(:quotes)
                        .group("rfqs.title")
                        .count

    # Savings Analytics
    @savings_data = calculate_savings_data

    # Auction Analytics
    @auctions_count = Auction.joins(:rfq).where(rfqs: { user_id: current_user.id }).count
    @active_auctions_count = Auction.active.joins(:rfq).where(rfqs: { user_id: current_user.id }).count

    # Top Suppliers
    @top_suppliers = Quote.joins(:rfq, :user)
                         .where(rfqs: { user_id: current_user.id })
                         .group("users.company_name")
                         .average(:price)
                         .sort_by { |_, v| v }
                         .first(5)
                         .to_h
  rescue ZeroDivisionError
    @avg_quotes_per_rfq = 0
  end

  private

  def calculate_savings_data
    savings = {}

    current_user.rfqs.includes(:quotes, :auction).each do |rfq|
      next if rfq.quotes.empty?

      highest_quote = rfq.quotes.maximum(:price)
      lowest_quote = rfq.quotes.minimum(:price)

      if rfq.auction && rfq.auction.current_price
        winning_price = rfq.auction.current_price
      else
        winning_price = lowest_quote
      end

      savings[rfq.title] = ((highest_quote - winning_price) / highest_quote * 100).round(2)
    end

    savings
  end
end
