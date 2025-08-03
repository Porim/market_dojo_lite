require "csv"

class ReportsController < ApplicationController
  before_action :require_buyer!

  def index
    # Main reports dashboard
  end

  def spend_analysis
    @start_date = params[:start_date]&.to_date || 3.months.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current

    # Total spend by month
    @spend_by_month = Quote.joins(:rfq)
                           .where(rfqs: { user_id: current_user.id, status: "closed" })
                           .where(created_at: @start_date..@end_date)
                           .group_by_month(:created_at)
                           .sum(:price)

    # Top categories by spend
    @top_categories = Quote.joins(:rfq)
                           .where(rfqs: { user_id: current_user.id, status: "closed" })
                           .where(created_at: @start_date..@end_date)
                           .group("rfqs.title")
                           .sum(:price)
                           .sort_by { |_, v| -v }
                           .first(10)

    # Savings analysis
    @savings_data = calculate_savings_analysis(@start_date, @end_date)

    respond_to do |format|
      format.html
      format.csv { send_data generate_spend_csv, filename: "spend_analysis_#{Date.current}.csv" }
      format.pdf {
        # For now, redirect to CSV export as PDF generation requires additional setup
        redirect_to spend_analysis_reports_path(format: :csv),
                    alert: "PDF export is not yet available. Downloading CSV instead."
      }
    end
  end

  def supplier_performance
    @suppliers = User.suppliers.joins(quotes: :rfq)
                     .where(rfqs: { user_id: current_user.id })
                     .group("users.id")
                     .select('users.*,
                             COUNT(DISTINCT quotes.id) as total_quotes,
                             AVG(quotes.price) as avg_price,
                             COUNT(DISTINCT rfqs.id) as rfqs_participated')
                     .to_a

    # Response time analysis
    if ActiveRecord::Base.connection.adapter_name == "SQLite"
      @response_times = Quote.joins(:rfq, :user)
                             .where(rfqs: { user_id: current_user.id })
                             .group("users.company_name")
                             .average("(julianday(quotes.created_at) - julianday(rfqs.created_at)) * 24")
    else
      @response_times = Quote.joins(:rfq, :user)
                             .where(rfqs: { user_id: current_user.id })
                             .group("users.company_name")
                             .average("EXTRACT(EPOCH FROM (quotes.created_at - rfqs.created_at))/3600")
    end

    # Win rate by supplier
    @win_rates = calculate_supplier_win_rates
  end

  def rfq_analytics
    @rfq_stats = {
      total: current_user.rfqs.count,
      published: current_user.rfqs.published.count,
      closed: current_user.rfqs.closed.count,
      draft: current_user.rfqs.draft.count
    }

    # Average quotes per RFQ over time
    @quotes_per_rfq = current_user.rfqs
                                  .joins(:quotes)
                                  .group_by_month(:created_at)
                                  .average("(SELECT COUNT(*) FROM quotes WHERE quotes.rfq_id = rfqs.id)")

    # RFQ cycle time (from creation to closure)
    @cycle_times = current_user.rfqs
                               .where(status: "closed")
                               .where.not(updated_at: nil)
                               .pluck(:created_at, :updated_at)
                               .map { |created, updated| (updated - created) / 1.day }

    @avg_cycle_time = @cycle_times.any? ? @cycle_times.sum / @cycle_times.size : 0
  end

  def custom_report
    # Allow users to build custom reports
    @available_metrics = [
      "Total Spend", "Number of RFQs", "Average Quote Value",
      "Supplier Count", "Savings Percentage", "Response Rate"
    ]

    @available_dimensions = [
      "Time Period", "Supplier", "Category", "Status"
    ]

    if params[:metrics].present? && params[:dimensions].present?
      @report_data = generate_custom_report(params[:metrics], params[:dimensions], params[:filters])
    end

    respond_to do |format|
      format.html
      format.csv { send_data generate_custom_csv(@report_data), filename: "custom_report_#{Date.current}.csv" }
      format.pdf {
        # For now, redirect to CSV export as PDF generation requires additional setup
        redirect_to custom_report_reports_path(format: :csv, metrics: params[:metrics], dimensions: params[:dimensions]),
                    alert: "PDF export is not yet available. Downloading CSV instead."
      }
    end
  end

  private

  def calculate_savings_analysis(start_date, end_date)
    savings = []

    current_user.rfqs.closed.where(updated_at: start_date..end_date).each do |rfq|
      quotes = rfq.quotes.order(:price)
      next if quotes.count < 2

      highest = quotes.last.price
      lowest = quotes.first.price
      savings_amount = highest - lowest
      savings_percentage = (savings_amount / highest * 100).round(2)

      savings << {
        rfq: rfq.title,
        highest_quote: highest,
        lowest_quote: lowest,
        savings_amount: savings_amount,
        savings_percentage: savings_percentage
      }
    end

    savings.sort_by { |s| -s[:savings_amount] }
  end

  def calculate_supplier_win_rates
    win_rates = {}

    User.suppliers.each do |supplier|
      total_quotes = supplier.quotes.joins(:rfq).where(rfqs: { user_id: current_user.id }).count
      winning_quotes = supplier.quotes.joins(:rfq)
                              .where(rfqs: { user_id: current_user.id, status: "closed" })
                              .where("quotes.price = (SELECT MIN(price) FROM quotes q2 WHERE q2.rfq_id = rfqs.id)")
                              .count

      win_rates[supplier.company_name] = total_quotes > 0 ? (winning_quotes.to_f / total_quotes * 100).round(2) : 0
    end

    win_rates.sort_by { |_, rate| -rate }.to_h
  end

  def generate_spend_csv
    CSV.generate(headers: true) do |csv|
      csv << [ "Month", "Total Spend", "Number of RFQs", "Average Quote Value" ]

      @spend_by_month.each do |month, spend|
        rfq_count = current_user.rfqs.where(created_at: month.beginning_of_month..month.end_of_month).count
        avg_value = rfq_count > 0 ? spend / rfq_count : 0

        csv << [ month.strftime("%B %Y"), spend, rfq_count, avg_value ]
      end
    end
  end

  def generate_custom_report(metrics, dimensions, filters)
    # Implementation for custom report generation
    # This would be more complex in a real application
    {}
  end

  def generate_custom_csv(report_data)
    CSV.generate(headers: true) do |csv|
      csv << [ "Custom Report - Generated on #{Date.current}" ]
      csv << [] # Empty row

      # Add headers based on selected metrics and dimensions
      headers = (params[:dimensions] || []) + (params[:metrics] || [])
      csv << headers if headers.any?

      # Placeholder data - in a real app, this would be the actual report data
      csv << [ "No data available - please implement custom report generation" ]
    end
  end
end
