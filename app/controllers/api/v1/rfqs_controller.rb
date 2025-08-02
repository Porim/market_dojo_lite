module Api
  module V1
    class RfqsController < BaseController
      before_action :set_rfq, only: [ :show, :update, :destroy ]
      before_action :authorize_buyer!, only: [ :create, :update, :destroy ]

      def index
        @rfqs = if current_api_user.buyer?
                  current_api_user.rfqs
        else
                  Rfq.published
        end

        @rfqs = @rfqs.includes(:user, :quotes)
                     .page(params[:page])
                     .per(params[:per_page] || 20)

        render json: {
          rfqs: @rfqs.map { |rfq| rfq_json(rfq) },
          meta: pagination_dict(@rfqs)
        }
      end

      def show
        render json: { rfq: detailed_rfq_json(@rfq) }
      end

      def create
        @rfq = current_api_user.rfqs.build(rfq_params)

        if @rfq.save
          if @rfq.published?
            send_rfq_notifications(@rfq)
          end
          render json: { rfq: detailed_rfq_json(@rfq) }, status: :created
        else
          render json: { errors: @rfq.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @rfq.update(rfq_params)
          render json: { rfq: detailed_rfq_json(@rfq) }
        else
          render json: { errors: @rfq.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @rfq.destroy
        head :no_content
      end

      private

      def set_rfq
        @rfq = if current_api_user.buyer?
                 current_api_user.rfqs.find(params[:id])
        else
                 Rfq.published.find(params[:id])
        end
      end

      def authorize_buyer!
        unless current_api_user.buyer?
          render json: { error: "Only buyers can perform this action" }, status: :forbidden
        end
      end

      def rfq_params
        params.require(:rfq).permit(:title, :description, :deadline, :status)
      end

      def rfq_json(rfq)
        {
          id: rfq.id,
          title: rfq.title,
          status: rfq.status,
          deadline: rfq.deadline,
          quotes_count: rfq.quotes.count,
          user: {
            id: rfq.user.id,
            name: rfq.user.name,
            company_name: rfq.user.company_name
          },
          created_at: rfq.created_at,
          updated_at: rfq.updated_at
        }
      end

      def detailed_rfq_json(rfq)
        rfq_json(rfq).merge(
          description: rfq.description,
          quotes: rfq.quotes.map { |q| quote_json(q) },
          documents: rfq.documents.map { |d| document_json(d) }
        )
      end

      def quote_json(quote)
        {
          id: quote.id,
          price: quote.price,
          notes: quote.notes,
          supplier: {
            id: quote.user.id,
            name: quote.user.name,
            company_name: quote.user.company_name
          },
          created_at: quote.created_at
        }
      end

      def document_json(document)
        {
          id: document.id,
          filename: document.filename.to_s,
          byte_size: document.byte_size,
          content_type: document.content_type,
          download_url: rails_blob_url(document)
        }
      end

      def send_rfq_notifications(rfq)
        User.suppliers.joins(:email_preference).where(email_preferences: { rfq_created: true }).find_each do |supplier|
          NotificationMailer.rfq_created(rfq, supplier).deliver_later
        end
      end
    end
  end
end
