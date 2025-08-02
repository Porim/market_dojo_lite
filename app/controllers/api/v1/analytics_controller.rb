module Api
  module V1
    class AnalyticsController < BaseController
      before_action :authorize_buyer!

      def summary
        render json: {
          analytics: {
            total_rfqs: current_api_user.rfqs.count,
            active_rfqs: current_api_user.rfqs.active.count,
            total_quotes: Quote.joins(:rfq).where(rfqs: { user_id: current_api_user.id }).count,
            average_quotes_per_rfq: average_quotes_per_rfq,
            total_savings: calculate_total_savings,
            rfqs_by_status: rfqs_by_status,
            quotes_by_month: quotes_by_month,
            top_suppliers: top_suppliers
          }
        }
      end

      def rfq_details
        rfq = current_api_user.rfqs.find(params[:rfq_id])

        render json: {
          rfq: {
            id: rfq.id,
            title: rfq.title,
            status: rfq.status,
            quotes_count: rfq.quotes.count,
            average_quote_price: rfq.quotes.average(:price),
            lowest_quote_price: rfq.quotes.minimum(:price),
            highest_quote_price: rfq.quotes.maximum(:price),
            potential_savings: calculate_rfq_savings(rfq),
            quotes_timeline: rfq.quotes.group_by_day(:created_at).count
          }
        }
      end

      private

      def authorize_buyer!
        unless current_api_user.buyer?
          render json: { error: "Analytics are only available to buyers" }, status: :forbidden
        end
      end

      def average_quotes_per_rfq
        return 0 if current_api_user.rfqs.count == 0
        total_quotes = Quote.joins(:rfq).where(rfqs: { user_id: current_api_user.id }).count
        (total_quotes.to_f / current_api_user.rfqs.count).round(2)
      end

      def calculate_total_savings
        savings = 0
        current_api_user.rfqs.includes(:quotes).find_each do |rfq|
          next if rfq.quotes.empty?
          highest = rfq.quotes.maximum(:price)
          lowest = rfq.quotes.minimum(:price)
          savings += (highest - lowest) if highest && lowest
        end
        savings
      end

      def calculate_rfq_savings(rfq)
        return 0 if rfq.quotes.empty?
        highest = rfq.quotes.maximum(:price)
        lowest = rfq.quotes.minimum(:price)
        return 0 unless highest && lowest
        highest - lowest
      end

      def rfqs_by_status
        current_api_user.rfqs.group(:status).count
      end

      def quotes_by_month
        Quote.joins(:rfq)
             .where(rfqs: { user_id: current_api_user.id })
             .group_by_month(:created_at, last: 6)
             .count
      end

      def top_suppliers
        Quote.joins(:rfq, :user)
             .where(rfqs: { user_id: current_api_user.id })
             .group("users.id", "users.company_name")
             .order("COUNT(*) DESC")
             .limit(5)
             .pluck("users.company_name", "COUNT(*)", "AVG(quotes.price)")
             .map { |name, count, avg_price|
               {
                 company_name: name,
                 quotes_count: count,
                 average_price: avg_price.round(2)
               }
             }
      end
    end
  end
end
