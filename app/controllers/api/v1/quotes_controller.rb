module Api
  module V1
    class QuotesController < BaseController
      before_action :set_rfq
      before_action :set_quote, only: [ :show, :update, :destroy ]
      before_action :authorize_supplier!, only: [ :create ]
      before_action :authorize_quote_owner!, only: [ :update, :destroy ]

      def index
        @quotes = @rfq.quotes.includes(:user)
                      .page(params[:page])
                      .per(params[:per_page] || 20)

        render json: {
          quotes: @quotes.map { |quote| quote_json(quote) },
          meta: pagination_dict(@quotes)
        }
      end

      def show
        render json: { quote: quote_json(@quote) }
      end

      def create
        # Check if supplier already quoted
        if @rfq.quotes.exists?(user: current_api_user)
          render json: { error: "You have already submitted a quote for this RFQ" }, status: :unprocessable_entity
          return
        end

        @quote = @rfq.quotes.build(quote_params)
        @quote.user = current_api_user

        if @quote.save
          send_quote_notification(@quote)
          render json: { quote: quote_json(@quote) }, status: :created
        else
          render json: { errors: @quote.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @quote.update(quote_params)
          render json: { quote: quote_json(@quote) }
        else
          render json: { errors: @quote.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @quote.destroy
        head :no_content
      end

      private

      def set_rfq
        @rfq = Rfq.published.find(params[:rfq_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "RFQ not found or not accessible" }, status: :not_found
      end

      def set_quote
        @quote = @rfq.quotes.find(params[:id])
      end

      def authorize_supplier!
        unless current_api_user.supplier?
          render json: { error: "Only suppliers can submit quotes" }, status: :forbidden
        end
      end

      def authorize_quote_owner!
        unless @quote.user == current_api_user
          render json: { error: "You can only modify your own quotes" }, status: :forbidden
        end
      end

      def quote_params
        params.require(:quote).permit(:price, :notes)
      end

      def quote_json(quote)
        {
          id: quote.id,
          rfq_id: quote.rfq_id,
          price: quote.price,
          notes: quote.notes,
          supplier: {
            id: quote.user.id,
            name: quote.user.name,
            company_name: quote.user.company_name
          },
          created_at: quote.created_at,
          updated_at: quote.updated_at
        }
      end

      def send_quote_notification(quote)
        if quote.rfq.user.email_preference&.quote_received?
          NotificationMailer.quote_received(quote).deliver_later
        end
      end
    end
  end
end
